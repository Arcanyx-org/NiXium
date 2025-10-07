{ ... }:

# Infrastructure-wide Management of HTTPS Certificates

{
	security.acme = {
		acceptTerms = true;
		defaults.email = "kreyren@fsfe.org";
	};
}
