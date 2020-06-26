set termout off

-- Initialization

delete from UserPrivileges;
delete from Privileges;
delete from UserRoles;
delete from Roles;
delete from Users;

insert into Users values(1, 'admin', 'password');
insert into Roles values(1, 'ADMIN');
insert into UserRoles values(1, 1);

insert into Privileges values(1, 'INSERT');
insert into Privileges values(2, 'SELECT');

set termout on
