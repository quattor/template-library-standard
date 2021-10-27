# Template allowing to create the repository appropriate for Quattor releases

structure template repository/quattor_rc;

"name" = 'quattor_' + QUATTOR_REPOSITORY_RELEASE;
"owner" = "quattor-grid@lists.sourceforge.net";
"protocols" = {
    if ( QUATTOR_REPOSITORY_RELEASE >= '20') {
        repository_url = format('%s/%s', QUATTOR_REPOSITORY_RELEASE, OS_VERSION_PARAMS['major']);
    } else {
        repository_url = QUATTOR_REPOSITORY_RELEASE;
    };
    protocol_entry = dict(
                        "name", "http",
                        "url", format("http://yum.quattor.org/testing/%s", repository_url)
                        );
    list(protocol_entry);
};

