-- ====================================================================
-- QR Attendance System — Complete Database Migration (002_complete_schema.sql)
-- Conforming to Part J (Schema) & Part K (Security & RLS)
-- ====================================================================

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Institutions Table
CREATE TABLE IF NOT EXISTS institutions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    timezone TEXT DEFAULT 'UTC' NOT NULL,
    settings JSONB DEFAULT '{}'::jsonb NOT NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Profiles Table (Extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('admin', 'teacher', 'student')),
    student_id_number TEXT,
    institution_id UUID REFERENCES institutions(id) ON DELETE SET NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'pending')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Add student_id_number and status to profiles if they already existed
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS student_id_number TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'pending'));

-- 4. Departments Table
CREATE TABLE IF NOT EXISTS departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. Academic Terms Table
CREATE TABLE IF NOT EXISTS academic_terms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'archived', 'upcoming')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. Classes Table
CREATE TABLE IF NOT EXISTS classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE NOT NULL,
    department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
    academic_term_id UUID REFERENCES academic_terms(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    section TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Ensure department_id and academic_term_id exist on classes
ALTER TABLE classes ADD COLUMN IF NOT EXISTS department_id UUID REFERENCES departments(id) ON DELETE SET NULL;
ALTER TABLE classes ADD COLUMN IF NOT EXISTS academic_term_id UUID REFERENCES academic_terms(id) ON DELETE SET NULL;
ALTER TABLE classes ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive'));

-- 7. Subjects Table
CREATE TABLE IF NOT EXISTS subjects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE,
    class_id UUID REFERENCES classes(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    code TEXT NOT NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
ALTER TABLE subjects ADD COLUMN IF NOT EXISTS institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE;

-- 8. Class Enrollments Table (Students enrolled into classes)
CREATE TABLE IF NOT EXISTS enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE,
    class_id UUID REFERENCES classes(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    status TEXT DEFAULT 'enrolled' CHECK (status IN ('enrolled', 'dropped', 'completed')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(class_id, student_id)
);
ALTER TABLE enrollments ADD COLUMN IF NOT EXISTS institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE;
ALTER TABLE enrollments ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'enrolled' CHECK (status IN ('enrolled', 'dropped', 'completed'));

-- 9. Teacher Assignments Table
CREATE TABLE IF NOT EXISTS teacher_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE NOT NULL,
    class_id UUID REFERENCES classes(id) ON DELETE CASCADE NOT NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(teacher_id, subject_id, class_id)
);
ALTER TABLE teacher_assignments ADD COLUMN IF NOT EXISTS institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE;
ALTER TABLE teacher_assignments ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive'));

-- 10. Attendance Sessions Table
CREATE TABLE IF NOT EXISTS attendance_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE,
    class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE NOT NULL,
    teacher_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    qr_token TEXT NOT NULL,
    token_hash TEXT,
    starts_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    closed_at TIMESTAMP WITH TIME ZONE,
    is_closed BOOLEAN DEFAULT false NOT NULL,
    late_threshold_minutes INTEGER DEFAULT 10 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
ALTER TABLE attendance_sessions ADD COLUMN IF NOT EXISTS institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE;
ALTER TABLE attendance_sessions ADD COLUMN IF NOT EXISTS class_id UUID REFERENCES classes(id) ON DELETE CASCADE;
ALTER TABLE attendance_sessions ADD COLUMN IF NOT EXISTS token_hash TEXT;
ALTER TABLE attendance_sessions ADD COLUMN IF NOT EXISTS starts_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());
ALTER TABLE attendance_sessions ADD COLUMN IF NOT EXISTS closed_at TIMESTAMP WITH TIME ZONE;

-- 11. Attendance Records Table
CREATE TABLE IF NOT EXISTS attendance_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE,
    session_id UUID REFERENCES attendance_sessions(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    scanned_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('present', 'late', 'absent')),
    is_offline_synced BOOLEAN DEFAULT false NOT NULL,
    correction_reason TEXT,
    corrected_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(session_id, student_id)
);
ALTER TABLE attendance_records ADD COLUMN IF NOT EXISTS institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE;
ALTER TABLE attendance_records ADD COLUMN IF NOT EXISTS correction_reason TEXT;
ALTER TABLE attendance_records ADD COLUMN IF NOT EXISTS corrected_by UUID REFERENCES profiles(id) ON DELETE SET NULL;

-- 12. Backup History Table (Part L)
CREATE TABLE IF NOT EXISTS backup_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE,
    initiated_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    drive_file_id TEXT,
    filename TEXT NOT NULL,
    status TEXT DEFAULT 'completed' CHECK (status IN ('completed', 'failed', 'in_progress', 'restored')) NOT NULL,
    schema_version TEXT DEFAULT '1.0' NOT NULL,
    checksum TEXT,
    record_count INTEGER DEFAULT 0 NOT NULL,
    file_size_bytes BIGINT DEFAULT 0 NOT NULL,
    error_summary TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 13. Notifications Table (Part O)
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE,
    recipient_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 14. Audit Logs Table (Part E & Q)
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE,
    actor_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT,
    entity_id TEXT,
    details TEXT,
    reason TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS institution_id UUID REFERENCES institutions(id) ON DELETE CASCADE;
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS actor_id UUID REFERENCES profiles(id) ON DELETE SET NULL;
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS entity_type TEXT;
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS entity_id TEXT;
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS reason TEXT;
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- ====================================================================
-- RLS (Row Level Security) Policies
-- ====================================================================

ALTER TABLE institutions ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE academic_terms ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE backup_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Departments RLS
CREATE POLICY "View departments" ON departments FOR SELECT USING (true);
CREATE POLICY "Admins manage departments" ON departments FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
);

-- Academic Terms RLS
CREATE POLICY "View academic terms" ON academic_terms FOR SELECT USING (true);
CREATE POLICY "Admins manage academic terms" ON academic_terms FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
);

-- Backup History RLS
CREATE POLICY "Admins manage backup history" ON backup_history FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
);

-- Notifications RLS
CREATE POLICY "Users view own notifications" ON notifications FOR SELECT USING (auth.uid() = recipient_id);
CREATE POLICY "Users update own notifications" ON notifications FOR UPDATE USING (auth.uid() = recipient_id);
CREATE POLICY "Insert notifications" ON notifications FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- ====================================================================
-- Secure Stored Procedure: mark_attendance_secure
-- Validates:
-- 1. Active session matching QR token & not closed
-- 2. Server time against expiry (now() <= expires_at)
-- 3. Student enrollment in the session's class
-- 4. Duplicate prevention
-- 5. Late calculation using server time (now())
-- ====================================================================

CREATE OR REPLACE FUNCTION mark_attendance_secure(
    p_qr_token TEXT,
    p_student_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_session RECORD;
    v_class_id UUID;
    v_is_enrolled BOOLEAN;
    v_already_marked BOOLEAN;
    v_now TIMESTAMP WITH TIME ZONE := timezone('utc'::text, now());
    v_status TEXT;
    v_diff_minutes INTEGER;
    v_record_id UUID;
BEGIN
    -- 1. Check if session exists and is active
    SELECT s.*, subj.class_id as subject_class_id
    INTO v_session
    FROM attendance_sessions s
    JOIN subjects subj ON subj.id = s.subject_id
    WHERE s.qr_token = p_qr_token AND s.is_closed = false;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'code', 'INVALID_OR_CLOSED_SESSION',
            'message', 'Invalid, closed, or nonexistent attendance session.'
        );
    END IF;

    -- 2. Check Expiry using trusted server clock
    IF v_now > v_session.expires_at THEN
        RETURN jsonb_build_object(
            'success', false,
            'code', 'QR_EXPIRED',
            'message', 'Attendance QR Code has expired.'
        );
    END IF;

    -- 3. Check Enrollment in Class
    v_class_id := COALESCE(v_session.class_id, v_session.subject_class_id);
    IF v_class_id IS NOT NULL THEN
        SELECT EXISTS (
            SELECT 1 FROM enrollments
            WHERE class_id = v_class_id AND student_id = p_student_id
        ) INTO v_is_enrolled;

        -- If enrollments table has records for this class, enforce check
        IF NOT v_is_enrolled AND EXISTS (SELECT 1 FROM enrollments WHERE class_id = v_class_id) THEN
            RETURN jsonb_build_object(
                'success', false,
                'code', 'NOT_ENROLLED',
                'message', 'Student is not enrolled in this class.'
            );
        END IF;
    END IF;

    -- 4. Check for duplicate attendance
    SELECT EXISTS (
        SELECT 1 FROM attendance_records
        WHERE session_id = v_session.id AND student_id = p_student_id
    ) INTO v_already_marked;

    IF v_already_marked THEN
        RETURN jsonb_build_object(
            'success', false,
            'code', 'ALREADY_MARKED',
            'message', 'Attendance has already been recorded for this session.'
        );
    END IF;

    -- 5. Calculate Status using Server Time
    v_diff_minutes := EXTRACT(EPOCH FROM (v_now - v_session.starts_at)) / 60;
    IF v_diff_minutes > v_session.late_threshold_minutes THEN
        v_status := 'late';
    ELSE
        v_status := 'present';
    END IF;

    -- 6. Insert Attendance Record
    INSERT INTO attendance_records (
        session_id,
        student_id,
        scanned_at,
        status,
        is_offline_synced,
        institution_id
    ) VALUES (
        v_session.id,
        p_student_id,
        v_now,
        v_status,
        true,
        v_session.institution_id
    ) RETURNING id INTO v_record_id;

    -- 7. Audit Log
    INSERT INTO audit_logs (
        institution_id,
        actor_id,
        action,
        entity_type,
        entity_id,
        details
    ) VALUES (
        v_session.institution_id,
        p_student_id,
        'ATTENDANCE_MARKED',
        'attendance_record',
        v_record_id::text,
        'Attendance marked as ' || v_status || ' for session ' || v_session.id
    );

    RETURN jsonb_build_object(
        'success', true,
        'status', v_status,
        'message', 'Attendance marked successfully as ' || UPPER(v_status) || '!',
        'record_id', v_record_id,
        'scanned_at', v_now
    );
END;
$$;
