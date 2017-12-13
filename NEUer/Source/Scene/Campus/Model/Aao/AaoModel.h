//
//  EcardModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/11.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AaoStudentStatusBean;
@class AaoExaminationScheduleBean;
@class AaoStudentScheduleBean;
@class AaoStudentScoreBean;
@class AaoSchoolPrecautionBean;

typedef void(^AaoAuthorCallbackBlock)(BOOL success, NSString *message);
typedef void(^AaoQueryInfoBlock)(BOOL success, NSString *message);
typedef void(^AaoGetImageBlock)(BOOL success, UIImage *verifyImage);

typedef NS_ENUM(NSInteger, AaoAtionQueryType) {
    AaoAtionQueryTypeStudentSchedule = 0, // 课程表
    AaoAtionQueryTypeStudentScore, // 成绩
    // 其他的都不需要二次登录
};

typedef NS_ENUM(NSInteger, AaoTermType) {
    AaoTermTypeSemesterOneIn2010_2011 = 1,
    AaoTermTypeSemesterTwoIn2010_2011,
    AaoTermTypeSemesterOneIn2011_2012,
    AaoTermTypeSemesterTwoIn2011_2012,
    AaoTermTypeSemesterOneIn2012_2013,
    AaoTermTypeSemesterTwoIn2012_2013,
    AaoTermTypeSemesterOneIn2013_2014,
    AaoTermTypeSemesterTwoIn2013_2014,
    AaoTermTypeSemesterOneIn2014_2015,
    AaoTermTypeSemesterTwoIn2014_2015,
    AaoTermTypeSemesterOneIn2015_2016,
    AaoTermTypeSemesterTwoIn2015_2016,
    AaoTermTypeSemesterOneIn2016_2017,
    AaoTermTypeSemesterTwoIn2016_2017,
    AaoTermTypeSemesterOneIn2017_2018,
    AaoTermTypeSemesterTwoIn2017_2018,
};

@interface AaoModel : NSObject
@property (nonatomic, strong) AaoStudentStatusBean *statusInfo;
@property (nonatomic, strong) AaoExaminationScheduleBean *examInfo;
@property (nonatomic, strong) AaoSchoolPrecautionBean *precautionInfo;
@property (nonatomic, strong) NSArray <AaoStudentScheduleBean *> *scheduleInfoArray;
@property (nonatomic, strong) NSArray <AaoStudentScoreBean *> *scoreInfoArray;
@property (nonatomic, strong) NSArray <NSDictionary *>*scoreTypeArray;
@property (nonatomic, assign) AaoTermType currentTermType;


- (void)getVerifyImage:(AaoGetImageBlock)block;

- (void)authorUser:(NSString *)userName password:(NSString *)password verifyCode:(NSString *)verifyCode queryType:(AaoAtionQueryType)queryType callBack:(AaoAuthorCallbackBlock)callback;
/**
 查询考试日程
 */
- (void)queryExaminationScheduleWithBlock:(AaoQueryInfoBlock)block;

/**
 查询学籍信息
 */
- (void)queryStudentStatusWithBlock:(AaoQueryInfoBlock)block;

/**
 培养计划
 */
- (void)queryTrainingPlanWithBlock:(AaoQueryInfoBlock)block;

/**
 学业预警
 */
- (void)querySchoolPrecautionWithBlock:(AaoQueryInfoBlock)block;

/**
 设置当前学期类型
 */
- (void)setCurrentTermTypeWithName:(NSString *)name;

/**
 查询学生成绩
 */
- (void)queryStudentScoreWithTermType:(AaoTermType)termType Block:(AaoQueryInfoBlock)block;

@end

// 学业预警
@interface AaoSchoolPrecautionBean : NSObject
@property (nonatomic, strong) NSString *precaution_number; // 编号
@property (nonatomic, strong) NSString *precaution_curriculumName; // 课群名称
@property (nonatomic, strong) NSString *precaution_requiresCredits; // 计划学分
@property (nonatomic, strong) NSString *precaution_academicCredits; // 修读学分
@property (nonatomic, strong) NSString *precaution_affirmCredits; // 认定学分
@property (nonatomic, strong) NSString *precaution_factCredits; // 实际总学分
@property (nonatomic, strong) NSString *precaution_creditsDifference; // 学分差
@property (nonatomic, strong) NSString *precaution_faildCreditsSum; // 不及格学分和

@end

// 基本信息： 照片,sex,生源省市,出生日期,minzu,身份证号,englishName
//学籍信息：入学日期，层次，学习形式，学制，院校名称，分院(校)，考生号，专业名称，班号，当前所在级，学号，录取年份，录取批次，培养方式，学历类别，总分，招生季节，学籍状态
// 学籍信息
@interface AaoStudentStatusBean : NSObject
@property (nonatomic, strong) NSString *status_basicInfo; // 基本信息
@property (nonatomic, strong) NSString *status_name; // 姓名
@property (nonatomic, strong) UIImage *status_photo; // 照片
@property (nonatomic, strong) NSString *status_sex; // 性别
@property (nonatomic, strong) NSString *status_city; // 生源省市
@property (nonatomic, strong) NSString *status_birthDate; // 出生日期
@property (nonatomic, strong) NSString *status_nation; // 民族
@property (nonatomic, strong) NSString *status_IDNumber; // 身份证号
@property (nonatomic, strong) NSString *status_englishName; // englishName
@property (nonatomic, strong) NSString *status_statusInfo; // 学籍信息
@property (nonatomic, strong) NSString *status_enrollmentDate; // 入学日期
@property (nonatomic, strong) NSString *status_gradation; // 层次
@property (nonatomic, strong) NSString *status_studyMode; // 学习形式
@property (nonatomic, strong) NSString *status_eductionalSystme; // 学制
@property (nonatomic, strong) NSString *status_institution; // 院校名称
@property (nonatomic, strong) NSString *status_branchName; // 分院(校)
@property (nonatomic, strong) NSString *status_candidateNumber; // 考生号
@property (nonatomic, strong) NSString *status_major; // 专业名称
@property (nonatomic, strong) NSString *status_classNumber; // 班号
@property (nonatomic, strong) NSString *status_nowGrade; // 当前所在级
@property (nonatomic, strong) NSString *status_schoolNumber; // 学号
@property (nonatomic, strong) NSString *status_enrollYear; // 录取年份
@property (nonatomic, strong) NSString *status_enrollBatch; // 录取批次
@property (nonatomic, strong) NSString *status_trainingMode; // 培养方式
@property (nonatomic, strong) NSString *status_qualificationsType; // 学历类别
@property (nonatomic, strong) NSString *status_totalPoints; // 总分
@property (nonatomic, strong) NSString *status_admissionsSeason; // 招生季节
@property (nonatomic, strong) NSString *status_status; // 学籍状态



@end

//考试日程
@interface AaoExaminationScheduleBean : NSObject
@property (nonatomic, strong) NSString *exam_number; // 课程号
@property (nonatomic, strong) NSString *exam_name; // 课程名称
@property (nonatomic, strong) NSString *exam_curriculum; // 课程性质
@property (nonatomic, strong) NSString *exam_date; // 考试时间
@property (nonatomic, strong) NSString *exam_classroom; // 考试教室
@property (nonatomic, strong) NSString *exam_seatNumber; // 座位号
@property (nonatomic, strong) NSString *exam_placeName; // 考场名

@end

// 学生成绩
@interface AaoStudentScoreBean : NSObject
@property (nonatomic, strong) NSString *score_curriculum; // 课程性质
@property (nonatomic, strong) NSString *score_number; // 课程号
@property (nonatomic, strong) NSString *score_name; // 课程名称
@property (nonatomic, strong) NSString *score_examType; // 考试类型
@property (nonatomic, strong) NSString *score_period; // 学时
@property (nonatomic, strong) NSString *score_credit; // 学分
@property (nonatomic, strong) NSString *score_scoreType; // 成绩类型
@property (nonatomic, strong) NSString *score_dailyScore; // 平时成绩
@property (nonatomic, strong) NSString *score_midtermScore; // 期中成绩
@property (nonatomic, strong) NSString *score_finalScore; // 期末成绩
@property (nonatomic, strong) NSString *score_totalScore; // 总成绩

@end

// 学生课表
@interface AaoStudentScheduleBean : NSObject
@property (nonatomic, strong) NSString *schedule_courceName; // 课程名
@property (nonatomic, strong) NSString *schedule_teacherName; // 教师名
@property (nonatomic, strong) NSString *schedule_classroom; // 教室
@property (nonatomic, assign) NSInteger schedule_classPeriod; // 第几节课
@property (nonatomic, assign) NSInteger schedule_classDay; // 星期几
@property (nonatomic, assign) NSInteger schedule_beginWeek; // 开始周数
@property (nonatomic, assign) NSInteger schedule_endWeek; // 结束周数
@property (nonatomic, strong) UIColor *schedule_color; // 课程颜色
@property (nonatomic, strong) NSString *schedule_classWeek; // 开始周到结束周
@property (nonatomic, assign) NSInteger schedule_classSum; // 共几节
@property (nonatomic, strong) NSString *schedule_duringClasses; // 开始节数到结束节数

@end
