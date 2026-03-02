{ pkgs,... }:

{
	services.odoo = {
		enable = true;
		domain = "127.0.0.1";
		addons = [
			# (pkgs.fetchFromGitHub {
			# 	owner = "OCA";
			# 	repo = "bank-statement-import";
			# 	rev = "badd66db9b4061818ef47cd4c0c76cb0321a85bc";
			# 	sha256 = "sha256-DvLXgF65oB49jPjH0Qhy+nEjbNhoKJC+S0cYJSSBiqc=";
			# })
			# (pkgs.fetchFromGitHub {
			# 	owner = "OCA";
			# 	repo = "account-reconcile";
			# 	rev = "071e078a4cf50ae2451f91c23326b57c03716bd7";
			# 	sha256 = "sha256-nxy8tetb3yYxiI9px44+OgL4+i7kTODyj/zACtKsTjI=";
			# })
			# (pkgs.fetchFromGitHub {
			# 	owner = "OCA";
			# 	repo = "web";
			# 	rev = "1f8eb84f4dd571fff5e5805e7a5bdb5e3df1cd13";
			# 	sha256 = "sha256-5JIIhYJ/NJtClvNyFuBEapN6EWLn9AV710Qdi+WoQj0=";
			# })
			# (pkgs.fetchFromGitHub {
			# 	owner = "OCA";
			# 	repo = "project";
			# 	rev = "3f4b1865a7a156110eaf9433d896df4279f05e92";
			# 	sha256 = "sha256-iWLB/IVXqu9k9QchsnTV/oknzx+LcsDR3YX8QAohgRs=";
			# })
			# (pkgs.fetchFromGitHub {
			# 	owner = "OCA";
			# 	repo = "account-financial-tools";
			# 	rev = "09ec71abd1a1b0c36a623df3fb25e54a23498e85";
			# 	sha256 = "sha256-YFelhfuptI/iVPbzbSY/woyTjL/rPQaE0TENwzHh0W0=";
			# })
			# (pkgs.fetchFromGitHub {
			# 	owner = "OCA";
			# 	repo = "account-financial-reporting";
			# 	rev = "2b279ca0a12cd1c886efbcf3e3b968c58787d08e";
			# 	sha256 = "sha256-9oyRgSp0zqs0CmW1JhOhrPB4o6+5VwUFoygFAQCEwrU=";
			# })
			# (pkgs.fetchFromGitHub {
			# 	owner = "OCA";
			# 	repo = "reporting-engine";
			# 	rev = "63c9bde02dfbff038d77d6dbf3e42093a9b774b6";
			# 	sha256 = "sha256-DjorMensR0IRXQfAKLvGHF/eN0RLSquzauemXTfoSzQ=";
			# })
			# (pkgs.fetchFromGitHub {
			# 	owner = "OCA";
			# 	repo = "server-ux";
			# 	rev = "65598dfc49908705825eb2b7cbd8708f0a97e5c4";
			# 	sha256 = "sha256-hyk7fPZ3+xx1eEKuPTH21VQFvSAQ8AhMb9zA5Il7FxE=";
			# })
			(pkgs.fetchFromGitHub {
				owner = "OCA";
				repo = "server-brand";
				rev = "b6a1044f43158c5b846deb67c12effcd3c0ad323";
				sha256 = "sha256-tMRSYPsT74H/6EBsGKTyq0V6wYcFVFi+CASwIJxFhTw=";
			})
		];
		#autoInit = true;
		#autoInitExtraFlags = [ "--without-demo=all" ];

		settings = {
				options = {
					admin_passwd = "owo";
					#db_host = "svc-pg01.dd-ix.net";
					# db_port = 5432;
					db_user = "odoo";
					db_password = "owo";
					db_name = "odoo";
					# db_sslmode = "verify-full";
				};
			};
	};
}
