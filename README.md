PGR301 DevOps i skyen -Skriftlig individuell hjemmeeksamen

Kandidatnr.:57


Oppgave 1 - AWS Lambda

Leveranse 1 (A - HTTP Endepunkt for Lambdaf unkskonen)
https://54di67to21.execute-api.eu-west-1.amazonaws.com/Prod/hello

Leveranse 2 (B - GitHub Actions workflow SAM-applikasjonen)
https://github.com/davido0604/eksamen-2024-main/actions/runs/12020380133




Oppgave 2 - Infrastruktur med Terraform og SQS

Leveranse 1 (GitHub Actions workflow terraform main)
https://github.com/davido0604/eksamen-2024-main/actions/runs/12022364820

Leveranse 2 (GitHub Actions workflow terraform ikke main)
https://github.com/davido0604/eksamen-2024-main/actions/runs/12022418344

Leveranse 3 (SQS-Kø URL)
https://sqs.eu-west-1.amazonaws.com/244530008913/image-processing-queue-Kandidat57









Oppgave 3 - Javaklient og Docker

Leveranse 1 (Beskrivelse av taggestrategi)
Taggestrategien for oppgaven er basert på to ting: latest og Git commit SHA. latest viser alltid til den nyeste stabile versjonen av imaget, noe som gjør det lett for teamet å bruke den nyeste versjonen uten å måtte lete etter spesifikke tagger. Samtidig gir SHA-tagger, som er knyttet til hver commit, mulighet til å spore og bruke bestemte versjoner når det trengs. Denne løsningen er valgt fordi den gjør det enkelt i hverdagen samtidig som den gir god kontroll når man trenger å feilsøke eller teste eldre versjoner.



Leveranse 2 (Container image + SQS URL)
Container image: dadi002/java-sqs-client:latest
SQS URL: https://sqs.eu-west-1.amazonaws.com/244530008913/image-processing-queue-Kandidat57


GitHub Actions workflow container image til Docker Hub
https://github.com/davido0604/eksamen-2024-main/actions/runs/12022823751


Oppgave 4 - Metrics og overvåkning

Commit med implementasjon: 
https://github.com/davido0604/eksamen-2024-main/commit/e2c980c7e9928543c9439281d6812335b93bbd4d


Oppgave 5 - Serverless, Function as a service vs Container-teknologi

Når vi vurderer serverless arkitektur med FaaS som AWS lambda og meldingskøer som sqs, opp mot mikrotjenestebasert arkitektur, er det mange aspekter som skiller seg ut, spesielt når vi ser på DevOps-prinsipper som CI/CD, observability, skalerbarhet og eierskap. Her kommer min refleksjon etter å ha jobbet med dette gjennom oppgavene.


1. Automatisering og kontinuerlig levering (CI/CD)

En serverless arkitektur kan faktisk gjøre CI/CD enklere på noen måter, men også mer fragmentert. Når hver funksjon i lambda er en isolert komponent, kan man fokusere på små, målrettede enheter. Deployment kan gjøres raskt og med minimal overhead, men hvis du har mange funksjoner, kan det føles overveldende å holde oversikt over alle CI/CD-pipelines. Det blir som å måtte administrere flere små puslespillbrikker i stedet for en større helhet.

For mikrotjenester er CI/CD mer rett frem. Du bygger og deployer kanskje hele tjenesten som en docker container, noe som føles mer håndterbart hvis man allerede har erfaring med slike workflows. Men oppdateringene kan være tregere, siden hele tjenesten må deployes, selv for små endringer. Dessuten må man passe på kompatibilitet mellom forskjellige tjenester.

Jeg føler at serverless kan være mer effektivt hvis man virkelig investerer i automatiseringsverktøy som SAM eller Terraform, men det kan kreve mer fra teamet for å sette opp robuste pipelines i starten. Mikrotjenester har en litt høyere inngangsbillett for verktøy som Kubernetes, men er lettere å vedlikeholde når det først er oppe.

2. Observability (overvåkning)

Overvåkning i serverless kan være en utfordring fordi alt er fragmentert. Hver Lambda-funksjon har sine egne logger i CloudWatch, og hvis noe går galt, må man ofte hoppe mellom flere logger for å finne ut hva som skjedde. Hvis meldinger går via SQS, blir det enda mer utfordrende å spore hva som har skjedd. CloudWatch fungerer, men det er ikke alltid like lett å bruke når du vil ha et klart bilde av hele systemet.

Mikrotjenester gir mer kontroll fordi du kan samle all logging på ett sted, for eksempel i en fil eller en database. Det gjør feilsøking enklere fordi du kan følge hele flyten av en forespørsel gjennom tjenesten.

Jeg føler at serverless krever at man er veldig disiplinert med logging og overvåkning for å unngå kaos. Mikrotjenester føles litt mer håndterbart for meg akkurat nå, men jeg ser potensialet i serverless hvis man bruker gode verktøy.



3. Skalerbarhet og kostnadskontroll

Serverless er utrolig fleksibelt når det kommer til skalerbarhet. AWS lambda skalerer automatisk basert på trafikk, og du betaler bare for funksjonene når de faktisk kjører. Det er genialt for uforutsigbare arbeidsbelastninger. Men hvis en funksjon kjører veldig ofte eller lenge, kan det bli dyrt fordi du betaler per millisekund.

Mikrotjenester krever mer manuelt arbeid for å skalere. Du må konfigurere auto skalering for containerne eller serverne, noe som gir deg mer kontroll, men det tar tid å sette opp riktig. På den positive siden har du en fast kostnad hvis arbeidsbelastningen er stabil, fordi du allerede har allokert ressurser.

For meg virker serverless perfekt for små prosjekter eller systemer med uforutsigbar trafikk. Mikrotjenester gir mer forutsigbare kostnader og ytelse hvis man har et godt overblikk over trafikken.

4. Eierskap og ansvar

I en serverless arkitektur overlater du mye av infrastrukturen til AWS. De tar seg av skalering, patching og vedlikehold. Det er både bra og dårlig. Det er mindre ansvar for DevOps-teamet, men det betyr også at du har mindre kontroll. Hvis noe går galt med en lambda funksjon eller SQS, må du ofte vente på AWS for å løse problemet.

Med mikrotjenester har teamet full kontroll over infrastrukturen. Du styrer alt, fra servere til konfigurasjon. Det gir mer ansvar, men også mer fleksibilitet. Du kan tilpasse løsningen til dine behov uten å være avhengig av AWS begrensninger.

Jeg tror serverless er flott for mindre team som ikke har tid eller ressurser til å vedlikeholde kompleks infrastruktur. Mikrotjenester krever mer arbeid, men gir også større frihet.

Konklusjon

Å velge mellom serverless og mikrotjenester handler om hva slags behov prosjektet har. Serverless er perfekt for dynamiske, skalerbare systemer, men kan bli kaotisk hvis man ikke har gode rutiner for logging og CI/CD. Mikrotjenester er mer tradisjonelle og gir teamet mer kontroll, men krever mer arbeid for å håndtere skalering og vedlikehold.

Etter å ha jobbet med begge, ser jeg fordelene med serverless for spesifikke oppgaver, som bildegenerering med Lambda og SQS. Men mikrotjenester føles fortsatt som en tryggere løsning hvis teamet er vant til å håndtere infrastruktur. Jeg tror valget handler om å balansere fleksibilitet, kontroll og hvor mye teamet er villig til å vedlikeholde.
