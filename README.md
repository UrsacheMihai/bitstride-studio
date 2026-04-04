Informatii generale
- Categorie: Educational
- Judetul: Braila
- Surse: [GitHub - UrsacheMihai/bitstride_studio: Panou Administrare Studio](https://github.com/UrsacheMihai/bitstride_studio.git)

Descriere

"BitStride Studio" este back-office-ul (panoul de administrare secunadar) din spatele ecosistemului educațional BitStride. Proiectat cu o infrastructură solidă independentă de aplicația elevilor, Studio ia forma unei platforme ce permite curatorilor, profesorilor sau administratorilor de sistem să formeze, modereze și exporte complet asincron cursurile sau provocările viitoare de pe internet. Adoptă o abordare "creator-first", acționând ca primul scut defensiv vizavi de calitatea exercițiilor propuse.

Concret, aceasta îi permite cadrului didactic:
- să introducă dinamic lectii de teorie de programare utilizând un motor intern pentru formatarea conținutului.
- să simuleze ad-hoc teste "Mock IO", scriind la fel ca un utilizator cod pentru a verifica stabilitatea problemei pe un mediu izolat de compilație.
- să arhiveze capitole întregi exportându-le local sub formă fizică (`.zip`) pentru funcționalitatea de integrare static-delivery.
- să editeze, șteargă sau sincronizeze cursuri active utilizând direct cloud-ul Firebase (Force-Push pe baza rolurilor de acces RBAC).
 
**Important!**
**Proiectul a fost inceput in data de 15 Martie 2026 si a fost finalizat in data de 4 Aprilie 2026, dar toate commiturile au fost realizate in data de 4 Aprilie 2026, deoarace s-a lucrat in mediu local, și doar am creat commiturile nu și uploadat pe github, dând eronarea datei uploadului.**

Funcționalități Principale

    Sistem Preventiv și Corector Automat
    - Previne postarea publică a problemelor instabile. Panoul obligă profesorul să resolve la nivel de administrator problema concepută testând pe medii izolate API ieșirile. Până validarea nu trece la zero defecte, curicula e marcată ca incompletă.

    Modaluri Monospace pentru Mock IO
    - Include subcomponente dialog asincrone ce păstrează variabile "read-write", permițând scrierea conținutului fișierelor de intrare "fictive" care mai târziu ajung incluse direct în contextul clientului web.

    Extragere Sigură (Anti-Coliziune) de ID-uri
    - Modul de stocare generează chei semantice invizibile (bazate conceptual din combinări `uuid`) transformând titluri și denumiri simple în id-uri compatibile SEO pregătite pentru baze de date NoSQL.

    Securitate RBAC & Remote Deployment
    - Restricționează integral intrarea la platformă utilizatorilor care nu prezintă flag-ul de sistem corespunzător în token-ul generat de rețea.

Tehnologii

Aplicația "BitStride Studio" a fost construită folosind:

Frontend / Cadrul Nativ:
- Flutter / Dart - cadrul de dezvoltare asincron UI ce facilitează controlul performant de liste al exercițiilor multiple.
- UUID - librăria ajutătoare ce injectează string-uri de indecși la momentele formării problemelor abstracte.
- Archive - librăria de prelucrare "in-memory-array", utilizată intensivă pentru scrierea fizică sau maparea bufferelor în `.zip`-uri instantaneu ce asigură funcția de import/export curriculă.
- HTTP - pentru sincronizările de date cu API-ul compilatoarelor (verificarea corectitudinii enunțurilor).

Backend & Baza de Date:
- Firebase Core & Cloud Firestore - funcția de conector live bidirecțional. Studio împinge date către Firestore afectând public sistemul cursurilor pe site-ul de clienți.
- Firebase Auth - interzicerea traficului neautentificat pentru securizarea ecosistemului academic vizual.

Cerinte sistem

Platforme Suportate și Mediu de Lucru:
- Desktop (Recomandat): Windows 10+ sau interfață Web (Chrome/Edge desktop). Ideal pentru experiența de tastare rapidă curiculară în formatele Code Mock.
- Telefon / Tabletă (Android): Funcționabil pe Android 8.0+. Panoul funcționează perfect, dar tastarea de payload-uri I/O sau documente Markdown `.zip` pe ecrane mici nu este ergonomică.
- Conexiune la Internet: Obligatorie pentru a pătrunde sub protecția JWT Firestore și pentru interpelările directe cu API-urile compilatorului la validarea testelor.

Realizatori

**Mihai Ursache**
 - Scoala: Colegiul National "Nicolae Iorga"
 - Clasa: 10-a
 - Judet: Braila
 - Oras: Braila
