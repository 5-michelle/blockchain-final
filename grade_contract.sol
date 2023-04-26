// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract GradesContract {
    address public teacher;
    string [] subject;
    address[] studentIds;

    mapping (address => mapping(string => uint)) StudentGrades;
    mapping (string => bool) Subject;
    mapping (address => bool) Registered;
    mapping(uint => address) isStudent;
        
    constructor() {
        teacher = msg.sender;
    }

    // Bilid a new funciton to add new subject. (2.) 
    function addSubject(string memory subjectName) public {
        if(!Subject[subjectName]){
            subject.push(subjectName);
        }
    }
    
    // Use modifier to check. (6.)
    modifier isTeacher(){
        require(msg.sender == teacher, "only the teacher can call this method");
        _;
    } 

    function isGradesOf(address input) internal view returns (bool) {
        return (msg.sender == input);
    }

    modifier isTheStudentOrTeacher(address _address){
        require(isGradesOf(_address) || msg.sender == teacher, "only the student who owns these grades or the teacher can call this method");
        _;
    }

    // Bilid a new funciton to get subject grade. (3.)
    function getSubjectGrade(address studentId, string calldata _subjectName) public isTheStudentOrTeacher(studentId) view returns (uint) {
        return StudentGrades[studentId][_subjectName];
    }

    // Bilid a new funciton to put subject grade. (4.)
    function putSubjectGrade(address studentId, string calldata subjectName, uint subjectGrade) external isTeacher{
        // if it is first time registered
        if (Registered[studentId] == false) {
            // then add to Ids array for tracking or iterating
            studentIds.push(studentId);
            Registered[studentId] == true;
        }

        StudentGrades[studentId][subjectName] = subjectGrade;
    }

    // Revise three function below. (5.)
    function getGradesSum(address studentId) public isTheStudentOrTeacher(studentId) view returns (uint) {
        uint sum = 0;
        for (uint i = 0; i < subject.length; i++){
            sum = sum + StudentGrades[studentId][subject[i]];
        }

        return sum;
    }
    
    function getGradesAverage(address studentId) external isTheStudentOrTeacher(studentId) view returns (uint) {
        // Default every student have score of every subject. 
        return getGradesSum(studentId) / subject.length;
    }
    
    function getClassGradesAverage() external isTeacher view returns (uint) {
        // iterate all the grades and calculate its average
        uint sum = 0;
        uint studentNum = studentIds.length;

        for (uint i = 0; i < studentNum; i++) {
            sum = sum + getGradesSum(studentIds[i]);
        }

        // Default every student have score of every subject.         
        return (sum / studentNum) / subject.length;
    }
}