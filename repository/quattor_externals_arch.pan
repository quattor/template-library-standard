# Template allowing to create the repository appropriate for Quattor externals,
# based on current machine arch/os

structure template repository/quattor_externals_arch;

"name" = 'quattor_externals_arch';
"owner" = "quattor-grid@lists.sourceforge.net";
"protocols" = list(
    dict(
        "name", "http",
        "url", format(
                    "http://yum.quattor.org/externals/%s/%s%s",
                    OS_VERSION_PARAMS['arch'],
                    OS_VERSION_PARAMS['family'],
                    OS_VERSION_PARAMS['majorversion'],
                    )
        ),
);

