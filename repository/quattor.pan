# Template allowing to create the repository appropriate for Quattor releases

structure template repository/quattor;

"name" = 'quattor_' + QUATTOR_REPOSITORY_RELEASE;
"owner" = "quattor-grid@lists.sourceforge.net";
"protocols" = list(
  nlist("name","http",
        "url","http://yum.quattor.org/"+QUATTOR_REPOSITORY_RELEASE)
);

