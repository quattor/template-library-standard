# Template allowing to create the repository appropriate for Quattor release candidates

structure template repository/quattor_rc;

"name" = 'quattor_' + QUATTOR_REPOSITORY_RELEASE;
"owner" = "quattor-grid@lists.sourceforge.net";
"protocols" = list(
  nlist("name","http",
        "url","http://yum.quattor.org/testing/"+QUATTOR_REPOSITORY_RELEASE)
);

