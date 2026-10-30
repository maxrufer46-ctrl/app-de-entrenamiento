#!/usr/bin/env python3
"""Check project wiring and resource integrity without requiring Xcode or packages.

This is not a Swift compiler, availability checker or substitute for macOS tests.
Compatible with the Python 3 supplied by the Xcode 12.4 command-line tools.
"""

import json
import plistlib
import re
import sys
from pathlib import Path
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parent.parent


class OpenStep:
    """Read the dictionary/array/string subset used by Xcode project plists."""

    token_pattern = re.compile(
        r'\s+|//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"|[{}()=;,]|[^\s{}()=;,"]+',
        re.DOTALL,
    )

    def __init__(self, source):
        self.tokens = []
        position = 0
        while position < len(source):
            match = self.token_pattern.match(source, position)
            if match is None:
                raise ValueError("Invalid OpenStep token at byte {}".format(position))
            token = match.group()
            position = match.end()
            if token.isspace() or token.startswith(("//", "/*")):
                continue
            self.tokens.append(token)
        self.index = 0

    def consume(self, expected=None):
        if self.index >= len(self.tokens):
            raise ValueError("Unexpected end of OpenStep plist")
        token = self.tokens[self.index]
        self.index += 1
        if expected is not None and token != expected:
            raise ValueError("Expected {!r}, received {!r}".format(expected, token))
        return token

    def value(self):
        token = self.consume()
        if token == "{":
            result = {}
            while self.tokens[self.index] != "}":
                key = self.value()
                self.consume("=")
                if key in result:
                    raise ValueError("Duplicate OpenStep key: {}".format(key))
                result[key] = self.value()
                self.consume(";")
            self.consume("}")
            return result
        if token == "(":
            result = []
            while self.tokens[self.index] != ")":
                result.append(self.value())
                if self.tokens[self.index] == ",":
                    self.consume(",")
                elif self.tokens[self.index] != ")":
                    raise ValueError("Missing array separator")
            self.consume(")")
            return result
        if token.startswith('"'):
            return json.loads(token)
        return token

    def parse(self):
        result = self.value()
        if self.index != len(self.tokens):
            raise ValueError("Unexpected trailing OpenStep tokens")
        return result


def require(condition, message):
    if not condition:
        raise ValueError(message)


def read_text(path):
    return path.read_text(encoding="utf-8")


def check_project():
    project_path = ROOT / "FitTrack.xcodeproj/project.pbxproj"
    project = OpenStep(read_text(project_path)).parse()
    objects = project["objects"]
    require(int(project["objectVersion"]) <= 54, "Project format is newer than Xcode 12.4")
    require(project["rootObject"] in objects, "Missing root project object")

    def check_references(value):
        if isinstance(value, dict):
            for child in value.values():
                check_references(child)
        elif isinstance(value, list):
            for child in value:
                check_references(child)
        elif isinstance(value, str) and re.fullmatch(r"[A-F0-9]{24}", value):
            require(value in objects, "Dangling project reference: " + value)

    check_references(objects)
    for obj in objects.values():
        if obj["isa"] in ("PBXFileReference", "XCVersionGroup") and obj.get("sourceTree") == "SOURCE_ROOT":
            path = ROOT / obj["path"]
            require(not Path(obj["path"]).is_absolute(), "Absolute source path: " + obj["path"])
            require(path.exists(), "Missing project file: " + obj["path"])

    targets = {obj["name"]: obj for obj in objects.values() if obj["isa"] == "PBXNativeTarget"}
    require(set(targets) == {"FitTrack", "FitTrackTests", "FitTrackUITests"}, "Unexpected targets")
    expected_sources = {"FitTrack": set(), "FitTrackTests": set(), "FitTrackUITests": set()}
    for path in ROOT.rglob("*.swift"):
        relative = path.relative_to(ROOT).as_posix()
        target = "FitTrackUITests" if relative.startswith("Tests/UI/") else "FitTrackTests" if relative.startswith("Tests/") else "FitTrack"
        expected_sources[target].add(relative)

    model_path = "Models/Persistence/FitTrack.xcdatamodeld"
    expected_sources["FitTrack"].add(model_path)
    for name, target in targets.items():
        actual = []
        for phase_id in target["buildPhases"]:
            phase = objects[phase_id]
            if phase["isa"] == "PBXSourcesBuildPhase":
                for entry in phase["files"]:
                    actual.append(objects[objects[entry]["fileRef"]]["path"])
        require(len(actual) == len(set(actual)), "Duplicate sources in " + name)
        require(set(actual) == expected_sources[name], "Incorrect source membership for " + name)

    resources = []
    for phase_id in targets["FitTrack"]["buildPhases"]:
        phase = objects[phase_id]
        if phase["isa"] == "PBXResourcesBuildPhase":
            resources.extend(objects[objects[entry]["fileRef"]].get("name") for entry in phase["files"])
    require(set(resources) == {"Localizable.strings", "InfoPlist.strings"}, "Missing localized resources")

    scheme = ET.parse(ROOT / "FitTrack.xcodeproj/xcshareddata/xcschemes/FitTrack.xcscheme").getroot()
    for reference in scheme.iter("BuildableReference"):
        require(reference.attrib["BlueprintIdentifier"] in objects, "Broken shared scheme reference")
    testables = {item.find("BuildableReference").attrib["BlueprintName"] for item in scheme.findall("./TestAction/Testables/TestableReference")}
    require(testables == {"FitTrackTests", "FitTrackUITests"}, "Scheme must run both test targets")
    require(scheme.find("TestAction").attrib.get("codeCoverageEnabled") == "YES", "Coverage disabled in scheme")
    base = read_text(ROOT / "Config/Base.xcconfig")
    require(re.search(r"^MACOSX_DEPLOYMENT_TARGET\s*=\s*10\.15\s*$", base, re.MULTILINE) is not None, "Deployment target must remain 10.15")
    require(re.search(r"^SWIFT_VERSION\s*=\s*5\.0\s*$", base, re.MULTILINE) is not None, "Swift 5 language mode required")
    for path in (ROOT / "Config").glob("*.plist"):
        plistlib.loads(path.read_bytes())
    entitlements = plistlib.loads((ROOT / "Config/FitTrack.entitlements").read_bytes())
    require(entitlements.get("com.apple.security.app-sandbox") is True, "App Sandbox disabled")
    print("OK: Xcode project, file paths, 3 targets, shared scheme, plists and sandbox")


def check_model():
    directory = ROOT / "Models/Persistence/FitTrack.xcdatamodeld"
    current = plistlib.loads((directory / ".xccurrentversion").read_bytes())["_XCCurrentVersionName"]
    model = ET.parse(directory / current / "contents").getroot()
    entities = {entity.attrib["name"]: entity for entity in model.findall("entity")}
    require(len(entities) == 16, "Expected 16 phase-1 model entities")
    relationship_count = 0
    for name, entity in entities.items():
        attributes = {item.attrib["name"]: item for item in entity.findall("attribute")}
        require({"id", "createdAt", "updatedAt"}.issubset(attributes), "Missing identity/timestamps: " + name)
        unique = [[item.attrib["value"] for item in constraint] for constraint in entity.findall("./uniquenessConstraints/uniquenessConstraint")]
        require(["id"] in unique, "Missing UUID constraint: " + name)
        require(entity.attrib.get("representedClassName") == "NSManagedObject", "Unexpected model code generation")
        for relationship in entity.findall("relationship"):
            relationship_count += 1
            target_name = relationship.attrib["destinationEntity"]
            require(target_name in entities, "Unknown relationship destination")
            target = entities[target_name]
            inverse = target.find("./relationship[@name='{}']".format(relationship.attrib["inverseName"]))
            require(inverse is not None, "Missing inverse relationship")
            require(inverse.attrib["destinationEntity"] == name, "Wrong inverse destination")
            require(inverse.attrib["inverseName"] == relationship.attrib["name"], "Asymmetric inverse relationship")

    for entity_name, key in [("ProfileEntity", "scopeKey"), ("ActiveWorkoutStateEntity", "slotKey")]:
        keys = [item.attrib["value"] for item in entities[entity_name].findall("./uniquenessConstraints/uniquenessConstraint/constraint")]
        require(key in keys, "Missing singleton constraint on " + entity_name)
    for entity_name, relationship_name, rule in [
        ("RoutineEntity", "sessions", "Nullify"),
        ("RoutineEntity", "days", "Cascade"),
        ("ExerciseEntity", "sessionEntries", "Nullify"),
        ("WorkoutSessionEntity", "exercises", "Cascade"),
    ]:
        relation = entities[entity_name].find("./relationship[@name='{}']".format(relationship_name))
        require(relation is not None and relation.attrib["deletionRule"] == rule, "Unsafe deletion rule")
    print("OK: {} model entities, {} inverse relationships, UUID/singleton constraints and history preservation".format(len(entities), relationship_count))


def check_sources_and_localization():
    sources = list(ROOT.rglob("*.swift"))
    combined = "\n".join(read_text(path) for path in sources)
    code = re.sub(r"//[^\n]*|/\*.*?\*/", "", combined, flags=re.DOTALL)
    forbidden = [
        r"@(StateObject|AppStorage)\b", r"\b(NavigationStack|LazyVGrid|LazyHGrid|ProgressView|Grid|AsyncImage)\b",
        r"\b(await|actor|Task)\b", r"(?<!\.)\basync\b", r"\.(task|searchable|refreshable|onChange|fileImporter|fileExporter|keyboardShortcut|accessibilityIdentifier)\s*\(",
        r"Image\s*\(\s*systemName\s*:", r"NSImage\s*\(\s*systemSymbolName\s*:", r"import\s+(Charts|HealthKit|UIKit)\b",
        r"\btry\s*!", r"\bas\s*!", r"[\w\]\)]!(?!=)", r"\bfatalError\s*\(",
    ]
    for expression in forbidden:
        require(re.search(expression, code) is None, "Unsupported or unsafe Swift pattern: " + expression)
    entry_points = [path for path in sources if re.search(r"@main\b", read_text(path))]
    require(len(entry_points) == 1 and entry_points[0].name != "main.swift", "Invalid app entry point")
    require(not any(path.name == "main.swift" for path in sources), "main.swift conflicts with @main")

    translations = {}
    for locale in ["es", "en"]:
        path = ROOT / ("Resources/Localization/" + locale + ".lproj/Localizable.strings")
        translations[locale] = OpenStep("{" + read_text(path) + "}").parse()
        require(all(isinstance(value, str) and value for value in translations[locale].values()), "Empty translation")
    require(set(translations["es"]) == set(translations["en"]), "ES/EN keys differ")
    used = set(re.findall(r'NSLocalizedString\(\s*"([^"]+)"', combined))
    used.update(re.findall(r'add\(\s*"(menu\.[^"]+)"', combined))
    require(used.issubset(translations["es"]), "Missing translations: " + str(used - set(translations["es"])))
    for path in ROOT.rglob("*.md"):
        for target in re.findall(r"\]\(([^\s]+)\)", read_text(path)):
            if re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", target) or target.startswith("#"):
                continue
            require((path.parent / target.split("#")[0]).exists(), "Broken local documentation link: " + target)
    test_count = len(re.findall(r"func\s+test\w+\s*\(", combined))
    print("OK: {} Swift files, {} ES/EN keys, baseline API scan and local documentation links".format(len(sources), len(translations["es"])))
    print("Prepared {} XCTest methods; execution and coverage require Xcode on macOS.".format(test_count))


def main():
    try:
        check_project()
        check_model()
        check_sources_and_localization()
    except (ValueError, KeyError, IndexError, OSError, ET.ParseError) as error:
        print("FAILED: {}".format(error), file=sys.stderr)
        return 1
    print("Static checks passed. Swift compilation and Catalina runtime validation are still required.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
