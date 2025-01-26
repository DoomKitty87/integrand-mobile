class Assignment {
  String title = '';
  double score = 0.0;
  double scoreTotal = 0.0;

  double points = 0.0;
  double totalPoints = 0.0;

  AssignmentType type = AssignmentType(
    title: 'Default',
    weight: 1.0,
  );

  double get impact => totalPoints * type.weight;

  Assignment();

  Assignment.withValues({
    required this.title,
    required this.score,
    required this.scoreTotal,
    required this.type,
    required this.points,
    required this.totalPoints,
  });

  Assignment.testData({
    this.title = 'Test Assignment',
    this.score = 90.0,
    this.scoreTotal = 100.0,
  });
}

class AssignmentType {
  // eg. summative, formative, etc.
  String title = '';
  // weighted value of the assignment
  double weight = 0.0;

  double points = 0.0;
  double total = 0.0;

  AssignmentType({
    required this.title,
    required this.weight,
  });
}

class CourseGrading {
  String courseTitle = '';
  double grade = 0.0;
  List<AssignmentType> assignmentTypes = [];
  List<Assignment> assignments = [];

  CourseGrading clone() {
    CourseGrading newCourse = CourseGrading();
    newCourse.courseTitle = courseTitle;
    newCourse.grade = grade;
    newCourse.assignmentTypes = List.empty(growable: true);
    newCourse.assignments = List.empty(growable: true);
    for (var type in assignmentTypes) {
      newCourse.assignmentTypes.add(AssignmentType(
        title: type.title,
        weight: type.weight,
      ));
    }
    for (var assignment in assignments) {
      newCourse.assignments.add(Assignment.withValues(
        title: assignment.title,
        score: assignment.score,
        scoreTotal: assignment.scoreTotal,
        points: assignment.points,
        totalPoints: assignment.totalPoints,
        type: newCourse.assignmentTypes
            .firstWhere((element) => element.title == assignment.type.title),
      ));
    }
    return newCourse;
  }

  void calculateGrade() {
    double totalPoints = 0.0;
    double totalTotalPoints = 0.0;

    for (var assignment in assignments) {
      // print(assignment.title);
      // print(assignment.type.title);
      // print(assignment.type.weight);
      // print(assignment.points);
      // print(assignment.totalPoints);
      // print(assignment.score);
      // print(assignment.total);

      totalPoints += assignment.points * assignment.type.weight;
      totalTotalPoints += assignment.totalPoints * assignment.type.weight;
    }

    grade = totalPoints / totalTotalPoints * 4.0;
  }

  CourseGrading();

  CourseGrading.testData() {
    courseTitle = 'AP Calculus BC';
    grade = 3.72;
    assignmentTypes = [
      AssignmentType(
        title: 'Summative',
        weight: 0.6,
      ),
      AssignmentType(
        title: 'Formative',
        weight: 0.4,
      ),
    ];
    assignments = [
      Assignment.withValues(
        title: 'Test 1',
        score: 90.0,
        scoreTotal: 100.0,
        points: 90.0,
        totalPoints: 100.0,
        type: assignmentTypes[0],
      ),
      Assignment.withValues(
        title: 'Quiz 1',
        score: 95.0,
        scoreTotal: 100.0,
        points: 95.0,
        totalPoints: 100.0,
        type: assignmentTypes[1],
      ),
      Assignment.withValues(
        title: 'Test 2',
        score: 100.0,
        scoreTotal: 100.0,
        points: 100.0,
        totalPoints: 100.0,
        type: assignmentTypes[0],
      ),
      Assignment.withValues(
        title: 'Quiz 2',
        score: 85.0,
        scoreTotal: 100.0,
        points: 85.0,
        totalPoints: 100.0,
        type: assignmentTypes[1],
      ),
    ];
  }
}

class GradebookData {
  List<CourseGrading> courses = [];
  bool error = false;

  GradebookData();

  GradebookData.testData() {
    courses = [
      CourseGrading.testData(),
      CourseGrading.testData(),
      CourseGrading.testData(),
      CourseGrading.testData(),
      CourseGrading.testData(),
      CourseGrading.testData(),
      CourseGrading.testData(),
      CourseGrading.testData(),
    ];
  }
}

class GPAData {
  double unweightedGPA = 0.0;
  double weightedGPA = 0.0;

  int unweightedRank = 0;
  int weightedRank = 0;

  int totalStudents = 0;

  bool error = false;

  GPAData();

  GPAData.testData() {
    unweightedGPA = 4.0;
    weightedGPA = 4.2;

    unweightedRank = 1;
    weightedRank = 1;

    totalStudents = 100;
  }
}