use inc::Module::Install;
name 'Acme-Seclusion-JP';
all_from 'lib/Acme/Seclusion/JP.pm';

requires 'Acme::CPANAuthors';
requires 'Acme::CPANAuthors::Japanese';
requires 'Acme::CPANAuthors::Chinese';
requires 'Acme::CPANAuthors::Korean';
requires 'Acme::CPANAuthors::Dutch';
requires 'Module::CoreList';
requires 'CPAN::DistnameInfo';
requires 'Devel::GlobalDestruction';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
