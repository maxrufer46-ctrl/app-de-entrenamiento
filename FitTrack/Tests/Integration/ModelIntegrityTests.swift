import CoreData
import XCTest
@testable import FitTrack

final class ModelIntegrityTests: XCTestCase {
    func testDeletingRoutineKeepsSessionNameAndHistory() throws {
        let stack = try openedMemoryStack()
        try perform(in: stack) { context in
            let routine = insertedObject("RoutineEntity", in: context)
            let session = insertedObject("WorkoutSessionEntity", in: context)
            session.setValue(Date(), forKey: "startedAt")
            session.setValue("Full Body A", forKey: "routineNameSnapshot")
            session.setValue(routine, forKey: "routine")
            try context.save()
            context.delete(routine)
            try context.save()
            let sessions = try context.fetch(NSFetchRequest<NSManagedObject>(entityName: "WorkoutSessionEntity"))
            XCTAssertEqual(sessions.count, 1)
            XCTAssertEqual(sessions.first?.value(forKey: "routineNameSnapshot") as? String, "Full Body A")
            XCTAssertNil(sessions.first?.value(forKey: "routine"))
        }
    }

    func testDeletingExerciseKeepsPerformedExerciseSnapshot() throws {
        let stack = try openedMemoryStack()
        try perform(in: stack) { context in
            let exercise = insertedObject("ExerciseEntity", in: context)
            let session = insertedObject("WorkoutSessionEntity", in: context)
            session.setValue(Date(), forKey: "startedAt")
            let entry = insertedObject("SessionExerciseEntity", in: context)
            entry.setValue(session, forKey: "session")
            entry.setValue(exercise, forKey: "exercise")
            entry.setValue(exercise.value(forKey: "id"), forKey: "exerciseIDSnapshot")
            entry.setValue("Sentadilla", forKey: "nameESSnapshot")
            try context.save()
            context.delete(exercise)
            try context.save()
            XCTAssertEqual(entry.value(forKey: "nameESSnapshot") as? String, "Sentadilla")
            XCTAssertNil(entry.value(forKey: "exercise"))
            XCTAssertFalse(entry.isDeleted)
        }
    }

    func testDeletingRoutineCascadesThroughDaysAndPrescriptions() throws {
        let stack = try openedMemoryStack()
        try perform(in: stack) { context in
            let routine = insertedObject("RoutineEntity", in: context)
            let day = insertedObject("RoutineDayEntity", in: context)
            day.setValue(routine, forKey: "routine")
            let entry = insertedObject("RoutineExerciseEntity", in: context)
            entry.setValue(day, forKey: "day")
            let prescription = insertedObject("SetPrescriptionEntity", in: context)
            prescription.setValue(entry, forKey: "routineExercise")
            try context.save()
            context.delete(routine)
            try context.save()
            for entity in ["RoutineEntity", "RoutineDayEntity", "RoutineExerciseEntity", "SetPrescriptionEntity"] {
                XCTAssertEqual(try context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: entity)), 0)
            }
        }
    }
}
