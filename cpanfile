requires 'perl', '5.008008';

on 'test' => sub {
    requires 'Test::More', 0.98;
};

requires 'Moo', 2.005004;

requires 'Crypt::Passwd::XS', 0.601;
requires 'Crypt::PasswdMD5',  1.40;
requires 'Digest::SHA',       0;
