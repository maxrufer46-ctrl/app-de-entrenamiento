#!/bin/bash
# Native acceptance check: Catalina + Xcode 12.4, using the project's local ad-hoc signing.
set -euo pipefail

FITTRACK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$FITTRACK_ROOT"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Esta comprobación requiere un Mac con Catalina y Xcode 12.4." >&2
    exit 2
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
    echo "No se encuentra xcodebuild. Selecciona Xcode 12.4 con DEVELOPER_DIR." >&2
    exit 2
fi

FITTRACK_XCODE_VERSION="$(xcodebuild -version | head -n 1)"
if [[ "$FITTRACK_XCODE_VERSION" != "Xcode 12.4" ]]; then
    echo "Se requiere Xcode 12.4. Ajusta DEVELOPER_DIR para seleccionar esa instalación." >&2
    exit 2
fi

FITTRACK_OS_VERSION="$(sw_vers -productVersion)"
case "$FITTRACK_OS_VERSION" in
    10.15.*) ;;
    *) echo "La aceptación de compatibilidad debe ejecutarse en Catalina 10.15.x." >&2; exit 2 ;;
esac

python3 Scripts/validate_project.py
FITTRACK_RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
FITTRACK_RESULTS="TestResults/$FITTRACK_RUN_ID"
mkdir -p "$FITTRACK_RESULTS"

{
    sw_vers
    xcodebuild -version
    xcrun swift --version
    git rev-parse HEAD
} > "$FITTRACK_RESULTS/environment.txt"

xcodebuild -list -project FitTrack.xcodeproj > "$FITTRACK_RESULTS/project.txt"
for FITTRACK_CONFIGURATION in Debug Release; do
    xcodebuild -project FitTrack.xcodeproj -scheme FitTrack \
        -configuration "$FITTRACK_CONFIGURATION" -destination 'platform=macOS' \
        -derivedDataPath DerivedData build 2>&1 \
        | tee "$FITTRACK_RESULTS/build-$FITTRACK_CONFIGURATION.log"
done

xcodebuild -project FitTrack.xcodeproj -scheme FitTrack -configuration Debug \
    -destination 'platform=macOS' -derivedDataPath DerivedData \
    -enableCodeCoverage YES -resultBundlePath "$FITTRACK_RESULTS/Tests.xcresult" test 2>&1 \
    | tee "$FITTRACK_RESULTS/tests.log"

xcrun xccov view --report --json "$FITTRACK_RESULTS/Tests.xcresult" > "$FITTRACK_RESULTS/coverage.json"
echo "Builds y pruebas completados. Resultados: $FITTRACK_ROOT/$FITTRACK_RESULTS"
