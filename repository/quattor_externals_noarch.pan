# Template allowing to create the repository for Quattor noarch externals.

structure template repository/quattor_externals_noarch;

"name" = 'quattor_externals_noarch';
"owner" = "quattor-grid@lists.sourceforge.net";
"protocols" = list(
  dict("name", "http",
       "url", format("http://yum.quattor.org/externals/noarch/%s%s",
                     OS_VERSION_PARAMS['family'],
                     OS_VERSION_PARAMS['majorversion'])
       ),
);

