DROP TABLE IF EXISTS "users";
CREATE TABLE `users` (  id INTEGER PRIMARY KEY AUTOINCREMENT ,     login TEXT,    name TEXT,   password TEXT );
INSERT INTO "users" VALUES(1,'root','Superuser','cf2e875d70c402e4aaf32ceb64b1fa6f7396af59');
