-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Institutions table
create table if not exists institutions (
    id uuid primary key default uuid_generate_v4(),
    name text not null,
    code text unique not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Profiles table (extends auth.users)
create table if not exists profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    email text not null,
    full_name text not null,
    role text not null check (role in ('admin', 'teacher', 'student')),
    institution_id uuid references institutions(id) on delete set null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Classes table
create table if not exists classes (
    id uuid primary key default uuid_generate_v4(),
    name text not null,
    section text,
    institution_id uuid references institutions(id) on delete cascade not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Subjects table
create table if not exists subjects (
    id uuid primary key default uuid_generate_v4(),
    name text not null,
    code text not null,
    class_id uuid references classes(id) on delete cascade not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enrollments table (students in classes)
create table if not exists enrollments (
    id uuid primary key default uuid_generate_v4(),
    class_id uuid references classes(id) on delete cascade not null,
    student_id uuid references profiles(id) on delete cascade not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    unique(class_id, student_id)
);

-- Teacher assignments table
create table if not exists teacher_assignments (
    id uuid primary key default uuid_generate_v4(),
    teacher_id uuid references profiles(id) on delete cascade not null,
    subject_id uuid references subjects(id) on delete cascade not null,
    class_id uuid references classes(id) on delete cascade not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    unique(teacher_id, subject_id, class_id)
);

-- Attendance sessions table
create table if not exists attendance_sessions (
    id uuid primary key default uuid_generate_v4(),
    subject_id uuid references subjects(id) on delete cascade not null,
    teacher_id uuid references profiles(id) on delete cascade not null,
    qr_token text not null,
    expires_at timestamp with time zone not null,
    is_closed boolean default false not null,
    late_threshold_minutes integer default 10 not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Attendance records table
create table if not exists attendance_records (
    id uuid primary key default uuid_generate_v4(),
    session_id uuid references attendance_sessions(id) on delete cascade not null,
    student_id uuid references profiles(id) on delete cascade not null,
    scanned_at timestamp with time zone default timezone('utc'::text, now()) not null,
    status text not null check (status in ('present', 'late', 'absent')),
    is_offline_synced boolean default false not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    unique(session_id, student_id)
);

-- Audit logs table
create table if not exists audit_logs (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references profiles(id) on delete set null,
    action text not null,
    details text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on all tables
alter table institutions enable row level security;
alter table profiles enable row level security;
alter table classes enable row level security;
alter table subjects enable row level security;
alter table enrollments enable row level security;
alter table teacher_assignments enable row level security;
alter table attendance_sessions enable row level security;
alter table attendance_records enable row level security;
alter table audit_logs enable row level security;

-- RLS Policies
-- Profiles: Non-recursive clean policies
create policy "Authenticated users can view profiles" on profiles for select using (true);
create policy "Users can insert own profile" on profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);

-- Institutions
create policy "Anyone can view institutions" on institutions for select using (true);
create policy "Admins can manage institutions" on institutions for all using (
    exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'admin')
);

-- Classes
create policy "Institution members view classes" on classes for select using (
    exists (select 1 from profiles p where p.id = auth.uid() and p.institution_id = classes.institution_id)
);
create policy "Admins manage classes" on classes for all using (
    exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'admin' and p.institution_id = classes.institution_id)
);

-- Subjects
create policy "View subjects" on subjects for select using (
    exists (
        select 1 from classes c
        join profiles p on p.institution_id = c.institution_id
        where c.id = subjects.class_id and p.id = auth.uid()
    )
);
create policy "Admins manage subjects" on subjects for all using (
    exists (
        select 1 from classes c
        join profiles p on p.id = auth.uid() and p.role = 'admin'
        where c.id = subjects.class_id and p.institution_id = c.institution_id
    )
);

-- Enrollments
create policy "View enrollments" on enrollments for select using (
    exists (select 1 from profiles p where p.id = auth.uid() and (p.id = student_id or p.role in ('admin', 'teacher')))
);
create policy "Admins manage enrollments" on enrollments for all using (
    exists (
        select 1 from classes c
        join profiles p on p.id = auth.uid() and p.role = 'admin'
        where c.id = enrollments.class_id and p.institution_id = c.institution_id
    )
);

-- Teacher Assignments
create policy "View teacher assignments" on teacher_assignments for select using (
    exists (select 1 from profiles p where p.id = auth.uid() and (p.id = teacher_id or p.role = 'admin'))
);
create policy "Admins manage teacher assignments" on teacher_assignments for all using (
    exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'admin')
);

-- Attendance Sessions
create policy "View attendance sessions" on attendance_sessions for select using (
    exists (select 1 from profiles p where p.id = auth.uid())
);
create policy "Teachers and admins manage sessions" on attendance_sessions for all using (
    exists (select 1 from profiles p where p.id = auth.uid() and (p.role in ('admin', 'teacher')))
);

-- Attendance Records
create policy "View attendance records" on attendance_records for select using (
    exists (select 1 from profiles p where p.id = auth.uid() and (p.id = student_id or p.role in ('admin', 'teacher')))
);
create policy "Students insert own attendance or teachers insert" on attendance_records for insert with check (
    exists (select 1 from profiles p where p.id = auth.uid() and (p.id = student_id or p.role in ('admin', 'teacher')))
);
create policy "Teachers and admins update records" on attendance_records for update using (
    exists (select 1 from profiles p where p.id = auth.uid() and p.role in ('admin', 'teacher'))
);

-- Audit Logs
create policy "Admins view audit logs" on audit_logs for select using (
    exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'admin')
);
create policy "Insert audit logs" on audit_logs for insert with check (auth.uid() is not null);
