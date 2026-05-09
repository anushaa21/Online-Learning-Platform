-- =============================================
-- ROBUST DATABASE REBUILD AND SEED DATA (29 TABLES)
-- This script uses dynamic SQL to bypass batch compilation errors.
-- PLEASE CONNECT TO YOUR TARGET DATABASE (e.g., OnlineLearningPlatformDb)
-- BEFORE RUNNING THIS SCRIPT.
-- =============================================

-- 1. DROP ALL FOREIGN KEYS AND TABLES
DECLARE @DropSql NVARCHAR(MAX) = '';
SELECT @DropSql += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + 
               ' DROP CONSTRAINT ' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.foreign_keys;
SELECT @DropSql += 'DROP TABLE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.tables;
EXEC sp_executesql @DropSql;
PRINT 'Cleanup complete.';

-- 2. CREATE TABLES
CREATE TABLE [roles] (
    [Id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [Name] NVARCHAR(50) NOT NULL,
    [Description] NVARCHAR(255) NULL
);

CREATE TABLE [users] (
    [Id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [Username] NVARCHAR(50) NOT NULL,
    [Email] NVARCHAR(100) NOT NULL UNIQUE,
    [PasswordHash] NVARCHAR(MAX) NOT NULL,
    [created_at] DATETIME NOT NULL DEFAULT GETUTCDATE(),
    [RoleId] UNIQUEIDENTIFIER NULL REFERENCES roles(Id) ON DELETE SET NULL,
    [assessment_completed_at] DATETIME NULL,
    [has_completed_assessment] BIT NOT NULL DEFAULT 0,
    [is_active] BIT NOT NULL DEFAULT 1
);

CREATE TABLE [profiles] (
    [Id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [UserId] UNIQUEIDENTIFIER NOT NULL UNIQUE REFERENCES users(Id) ON DELETE CASCADE,
    [FirstName] NVARCHAR(50) NULL,
    [LastName] NVARCHAR(50) NULL,
    [AvatarUrl] NVARCHAR(500) NULL,
    [Description] NVARCHAR(500) NULL
);

CREATE TABLE [Categories] (
    [category_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [name] NVARCHAR(100) NOT NULL,
    [parent_id] UNIQUEIDENTIFIER NULL REFERENCES Categories(category_id),
    [description] NVARCHAR(MAX) NULL
);

CREATE TABLE [Courses] (
    [course_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [instructor_id] UNIQUEIDENTIFIER NOT NULL REFERENCES users(Id),
    [category_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Categories(category_id),
    [title] NVARCHAR(200) NOT NULL,
    [description] NVARCHAR(MAX) NULL,
    [price] DECIMAL(18, 2) NOT NULL,
    [status] NVARCHAR(50) NOT NULL,
    [created_at] DATETIME NOT NULL DEFAULT GETUTCDATE(),
    [image_url] NVARCHAR(MAX) NULL,
    [is_featured] BIT NOT NULL DEFAULT 0,
    [level] NVARCHAR(50) NOT NULL DEFAULT 'Beginner',
    [language] NVARCHAR(50) NOT NULL DEFAULT 'English',
    [rejection_reason] NVARCHAR(MAX) NULL
);

CREATE TABLE [Modules] (
    [module_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [course_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Courses(course_id) ON DELETE CASCADE,
    [title] NVARCHAR(200) NOT NULL,
    [order_index] INT NOT NULL,
    [description] NVARCHAR(MAX) NULL,
    [created_at] DATETIME NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE [Lessons] (
    [lesson_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [module_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Modules(module_id) ON DELETE CASCADE,
    [title] NVARCHAR(200) NOT NULL,
    [type] NVARCHAR(50) NOT NULL,
    [content_url] NVARCHAR(MAX) NULL,
    [video_url] NVARCHAR(MAX) NULL,
    [content] NVARCHAR(MAX) NULL,
    [duration] INT NULL,
    [order_index] INT NOT NULL,
    [created_at] DATETIME NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE [Enrollments] (
    [enrollment_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [user_id] UNIQUEIDENTIFIER NOT NULL REFERENCES users(Id),
    [course_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Courses(course_id),
    [enrolled_at] DATETIME NOT NULL DEFAULT GETUTCDATE(),
    [completed_at] DATETIME NULL,
    [status] NVARCHAR(50) NOT NULL DEFAULT 'Active',
    [LastViewedLessonId] UNIQUEIDENTIFIER NULL
);

CREATE TABLE [Course_Reviews] (
    [review_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [course_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Courses(course_id) ON DELETE CASCADE,
    [user_id] UNIQUEIDENTIFIER NOT NULL REFERENCES users(Id),
    [rating] INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    [comment] NVARCHAR(MAX),
    [created_at] DATETIME NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE [Quizzes] (
    [quiz_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [lesson_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Lessons(lesson_id) ON DELETE CASCADE,
    [title] NVARCHAR(200) NOT NULL,
    [passing_score] FLOAT NOT NULL DEFAULT 70
);

CREATE TABLE [Questions] (
    [question_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [quiz_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Quizzes(quiz_id) ON DELETE CASCADE,
    [content] NVARCHAR(MAX) NOT NULL,
    [type] NVARCHAR(20) NOT NULL DEFAULT 'MultipleChoice'
);

CREATE TABLE [Options] (
    [option_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [question_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Questions(question_id) ON DELETE CASCADE,
    [text] NVARCHAR(MAX) NOT NULL,
    [is_correct] BIT NOT NULL DEFAULT 0
);

CREATE TABLE [Quiz_Attempts] (
    [attempt_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [quiz_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Quizzes(quiz_id),
    [user_id] UNIQUEIDENTIFIER NOT NULL REFERENCES users(Id),
    [score] INT NOT NULL,
    [passed] BIT NOT NULL,
    [attempted_at] DATETIME NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE [Learning_Paths] (
    [path_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [title] NVARCHAR(200) NOT NULL,
    [description] NVARCHAR(MAX) NULL,
    [created_by_user_id] UNIQUEIDENTIFIER NULL REFERENCES users(Id),
    [price] DECIMAL(18, 2) NOT NULL DEFAULT 0,
    [status] NVARCHAR(50) NOT NULL DEFAULT 'Draft',
    [is_custom_path] BIT NOT NULL DEFAULT 0,
    [source_assessment_id] UNIQUEIDENTIFIER NULL,
    [created_at] DATETIME NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE [Path_Courses] (
    [path_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Learning_Paths(path_id) ON DELETE CASCADE,
    [course_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Courses(course_id) ON DELETE CASCADE,
    [order_index] INT NOT NULL,
    PRIMARY KEY ([path_id], [course_id])
);

CREATE TABLE [Lesson_Progress] (
    [progress_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [enrollment_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Enrollments(enrollment_id) ON DELETE CASCADE,
    [lesson_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Lessons(lesson_id),
    [is_completed] BIT NOT NULL DEFAULT 0,
    [last_accessed_at] DATETIME NULL,
    [last_watched_position] INT NULL,
    [transcript] NVARCHAR(MAX) NULL,
    [ai_summary] NVARCHAR(MAX) NULL,
    [ai_summary_status] NVARCHAR(50) NULL
);

CREATE TABLE [Lesson_Comments] (
    [comment_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [lesson_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Lessons(lesson_id) ON DELETE CASCADE,
    [user_id] UNIQUEIDENTIFIER NOT NULL REFERENCES users(Id),
    [content] NVARCHAR(MAX) NOT NULL,
    [parent_id] UNIQUEIDENTIFIER NULL REFERENCES Lesson_Comments(comment_id),
    [created_at] DATETIME NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE [Notifications] (
    [notification_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [user_id] UNIQUEIDENTIFIER NOT NULL REFERENCES users(Id) ON DELETE CASCADE,
    [message] NVARCHAR(MAX) NOT NULL,
    [type] NVARCHAR(50) NOT NULL DEFAULT 'General',
    [is_read] BIT NOT NULL DEFAULT 0,
    [created_at] DATETIME NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE [Orders] (
    [order_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [user_id] UNIQUEIDENTIFIER NOT NULL REFERENCES users(Id),
    [course_id] UNIQUEIDENTIFIER NULL REFERENCES Courses(course_id),
    [path_id] UNIQUEIDENTIFIER NULL REFERENCES Learning_Paths(path_id),
    [total_amount] DECIMAL(18, 2) NOT NULL,
    [status] NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    [created_at] DATETIME NOT NULL DEFAULT GETUTCDATE(),
    [expires_at] DATETIME NULL,
    [RowVersion] TIMESTAMP NOT NULL
);

CREATE TABLE [Transactions] (
    [transaction_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [order_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Orders(order_id) ON DELETE CASCADE,
    [amount] DECIMAL(18, 2) NOT NULL,
    [payment_method] NVARCHAR(50) NULL,
    [status] NVARCHAR(50) NOT NULL DEFAULT 'pending',
    [transaction_gate_id] NVARCHAR(100) NULL,
    [created_at] DATETIME NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE [Wishlists] (
    [wishlist_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [user_id] UNIQUEIDENTIFIER NOT NULL REFERENCES users(Id) ON DELETE CASCADE,
    [course_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Courses(course_id) ON DELETE CASCADE,
    [added_at] DATETIME NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE [Certificates] (
    [certificate_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [enrollment_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Enrollments(enrollment_id) ON DELETE CASCADE,
    [serial_number] NVARCHAR(100) NOT NULL,
    [issue_date] DATETIME NOT NULL DEFAULT GETUTCDATE(),
    [pdf_url] NVARCHAR(MAX) NULL
);

CREATE TABLE [Chat_Messages] (
    [message_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [sender_id] UNIQUEIDENTIFIER NOT NULL REFERENCES users(Id),
    [receiver_id] UNIQUEIDENTIFIER NULL REFERENCES users(Id),
    [content] NVARCHAR(MAX) NOT NULL,
    [is_from_admin] BIT NOT NULL DEFAULT 0,
    [sent_at] DATETIME NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE [Blogs] (
    [blog_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [title] NVARCHAR(200) NOT NULL,
    [content] NVARCHAR(MAX) NOT NULL,
    [author_id] UNIQUEIDENTIFIER NOT NULL REFERENCES users(Id),
    [status] NVARCHAR(50) NOT NULL DEFAULT 'Published',
    [created_at] DATETIME NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE [Assessment_Questions] (
    [question_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [question_text] NVARCHAR(500) NOT NULL,
    [question_type] NVARCHAR(50) NOT NULL,
    [category_id] UNIQUEIDENTIFIER NULL REFERENCES Categories(category_id) ON DELETE SET NULL,
    [order_index] INT NOT NULL,
    [is_active] BIT NOT NULL DEFAULT 1
);

CREATE TABLE [Assessment_Options] (
    [option_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [question_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Assessment_Questions(question_id) ON DELETE CASCADE,
    [option_text] NVARCHAR(300) NOT NULL,
    [skill_level] NVARCHAR(50) NULL,
    [category] NVARCHAR(100) NULL,
    [order_index] INT NOT NULL
);

CREATE TABLE [User_Assessments] (
    [assessment_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [user_id] UNIQUEIDENTIFIER NOT NULL REFERENCES users(Id),
    [completed_at] DATETIME NOT NULL DEFAULT GETUTCDATE(),
    [result_summary] NVARCHAR(MAX) NULL
);

CREATE TABLE [User_Answers] (
    [answer_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [assessment_id] UNIQUEIDENTIFIER NOT NULL REFERENCES User_Assessments(assessment_id) ON DELETE CASCADE,
    [question_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Assessment_Questions(question_id),
    [selected_option_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Assessment_Options(option_id)
);

CREATE TABLE [User_Learning_Path_Enrollments] (
    [enrollment_id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [user_id] UNIQUEIDENTIFIER NOT NULL REFERENCES users(Id),
    [path_id] UNIQUEIDENTIFIER NOT NULL REFERENCES Learning_Paths(path_id) ON DELETE CASCADE,
    [progress_percentage] INT NOT NULL DEFAULT 0,
    [status] NVARCHAR(50) NOT NULL DEFAULT 'Active',
    [enrolled_at] DATETIME NOT NULL DEFAULT GETUTCDATE(),
    [completed_at] DATETIME NULL
);

PRINT 'Tables created. Starting data seeding via dynamic SQL...';

-- 3. SEED INITIAL DATA (Using EXEC to avoid compilation checks)
DECLARE @SeedSql NVARCHAR(MAX) = N'
DECLARE @AdminRoleId UNIQUEIDENTIFIER = ''78901234-5678-9012-3456-789012345678''
DECLARE @InstructorRoleId UNIQUEIDENTIFIER = ''12345678-1234-1234-1234-123456789012''
DECLARE @UserRoleId UNIQUEIDENTIFIER = ''87654321-4321-4321-4321-210987654321''

INSERT INTO [roles] ([Id], [Name], [Description]) VALUES
(@AdminRoleId, ''Admin'', ''Platform Administrator''),
(@InstructorRoleId, ''Instructor'', ''Course Creator''),
(@UserRoleId, ''User'', ''Student'');

DECLARE @AdminId UNIQUEIDENTIFIER = ''00000000-0000-0000-0000-000000000001''
DECLARE @Instructor1Id UNIQUEIDENTIFIER = ''00000000-0000-0000-0000-000000000002''
DECLARE @Student1Id UNIQUEIDENTIFIER = ''00000000-0000-0000-0000-000000000003''
DECLARE @PasswordHash NVARCHAR(MAX) = ''$2a$11$rBNdBxYU5sVEm4q9qwABkuNjh4BjY5RmZxB.1HbJvSZMVvxFCz0z6''

INSERT INTO [users] ([Id], [Username], [Email], [PasswordHash], [RoleId], [is_active], [has_completed_assessment]) VALUES
(@AdminId, ''admin'', ''admin@learnhub.com'', @PasswordHash, @AdminRoleId, 1, 0),
(@Instructor1Id, ''john.smith'', ''john.smith@learnhub.com'', @PasswordHash, @InstructorRoleId, 1, 1),
(@Student1Id, ''alice.nguyen'', ''alice.nguyen@gmail.com'', @PasswordHash, @UserRoleId, 1, 1);

INSERT INTO [profiles] ([UserId], [FirstName], [LastName], [AvatarUrl], [Description]) VALUES
(@AdminId, ''System'', ''Admin'', ''https://ui-avatars.com/api/?name=Admin'', ''Administrator account''),
(@Instructor1Id, ''John'', ''Smith'', ''https://ui-avatars.com/api/?name=John+Smith'', ''Expert Developer''),
(@Student1Id, ''Alice'', ''Nguyen'', ''https://ui-avatars.com/api/?name=Alice+Nguyen'', ''Aspiring Student'');

DECLARE @WebDev UNIQUEIDENTIFIER = NEWID()
DECLARE @DataScience UNIQUEIDENTIFIER = NEWID()
INSERT INTO [Categories] ([category_id], [name], [description]) VALUES
(@WebDev, ''Web Development'', ''HTML, CSS, JS, and frameworks''),
(@DataScience, ''Data Science'', ''Python, AI, and Machine Learning'');

DECLARE @Course1 UNIQUEIDENTIFIER = ''C1111111-1111-1111-1111-111111111111''
INSERT INTO [Courses] ([course_id], [instructor_id], [category_id], [title], [description], [price], [status], [is_featured], [level]) VALUES
(@Course1, @Instructor1Id, @WebDev, ''Complete ASP.NET Core MVC'', ''Learn MVC from scratch'', 599000, ''Published'', 1, ''Intermediate'');

DECLARE @Module1 UNIQUEIDENTIFIER = NEWID()
INSERT INTO [Modules] ([module_id], [course_id], [title], [order_index]) VALUES
(@Module1, @Course1, ''Introduction'', 1);

DECLARE @Lesson1 UNIQUEIDENTIFIER = NEWID()
INSERT INTO [Lessons] ([lesson_id], [module_id], [title], [type], [video_url], [order_index]) VALUES
(@Lesson1, @Module1, ''Course Overview'', ''Video'', ''https://online-learning-platform.sfo3.cdn.digitaloceanspaces.com/mvclagi.mp4'', 1);

INSERT INTO [Enrollments] ([enrollment_id], [user_id], [course_id], [enrolled_at], [status], [LastViewedLessonId]) VALUES
(NEWID(), @Student1Id, @Course1, GETUTCDATE(), ''Active'', @Lesson1);
';

EXEC sp_executesql @SeedSql;
PRINT 'Schema Rebuild and Seed Data complete. All 29 tables are ready.';
