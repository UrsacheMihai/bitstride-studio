# BitStride Studio

## Informatii generale

* **Categorie**: Educational
* **Judetul**: Brăila
* **Surse**: GitHub - [UrsacheMihai/bitstride-studio](https://github.com/UrsacheMihai/bitstride-studio)

## Descriere

“BitStride Studio” este portalul administrativ complementar conceput pentru profesori și creatorii de conținut din cadrul platformei educaționale BitStride. Acesta permite managementul facil al lecțiilor în format Markdown, proiectarea de provocări de programare (provocări de tip "challenge"), configurarea fișierelor de testare pentru evaluatorul automat și recenzarea manuală sau grading-ul trimiterilor făcute de elevi.

Concret, aceasta îi permite utilizatorului:
* să creeze și să editeze module de cursuri și structura syllabus-ului;
* să scrie textul lecțiilor într-un editor Markdown avansat, cu previzualizare în timp real;
* să configureze provocări de programare, adăugând manual sau dinamic cazuri de testare (intrări/ieșiri așteptate) și șabloane de cod inițial;
* să valideze funcționarea testelor prin compilare automată înainte de a le publica în baza de date;
* să exploreze, compare și să aprobe soluțiile trimise de elevi prin intermediul unui panou de administrare intuitiv.

## Funcționalități

### Manager Curriculă & Lecții
* **Editor Markdown**: Instrument de editare a conținutului lecțiilor cu suport pentru formatare și vizualizare instantanee a rezultatului.
* **Structurare curs**: Aranjarea intuitivă a capitolelor și capitolelor secundare din programa școlară.

### Designer de Provocări (Coding Challenge Creator)
* Adăugarea de titlu, descriere, grad de dificultate și tag-uri de limbaj (C++ / Python).
* Formulare dinamice pentru definirea fișierelor de testare cu limitări specifice (timp și memorie).
* Generator de șabloane de cod inițial pentru a îndruma elevii în rezolvare.

### Rularea și Evaluarea Testelor (Studio Judge)
* **Verificare compilare**: Permite administratorului să testeze propria rezolvare a provocării pe seturile de testare folosind evaluatorul la distanță înainte de publicare.
* Sincronizare automată și stocare securizată direct în Cloud Firestore.

### Panou de Recenzare (Review Dashboard)
* Vizualizarea soluțiilor de cod transmise de elevi.
* Carduri de comparație vizuală și actualizarea manuală a scorurilor sau acordarea de feedback.

---

## Tehnologii

Aplicația “BitStride Studio” a fost construită folosind:
* **Flutter SDK 3.22.x+** - Cadru pentru construirea interfeței web/native de administrare.
* **Dart 3.5.4+** - Limbaj de programare reactiv.
* **Cloud Firestore & Firebase Auth** - Sincronizarea securizată a conținutului educațional și controlul accesului administrativ.
* **Piston Compiler API & Cloudflare Tunnel** - Validarea soluțiilor de testare la distanță.

---

## Cerinte sistem

* **Sistem de operare**: Android 6.0 (API 23) sau superior / Browser modern capabil de WebGL și Canvas (Chrome, Safari, Firefox).
* **Conectare internet**: Necesară pentru autentificare admin, salvare în baza de date și testarea codului.

---

## Realizatori

**Ursache Mihai-Andrei**
* **Scoala**: Colegiul Național „Nicolae Iorga” Brăila
* **Clasa**: a X-a
* **Judet**: Brăila
* **Oras**: Brăila

---

## Documentație Tehnică & Wiki

Pentru detalii profunde despre arhitectură, componente și structură, consultați:
* [Developer Wiki (EN)](wikis/bitstride_studio_wiki.md)
* [Developer Wiki (RO)](wikis/bitstride_studio_wiki_ro.md)
* [Documentație Tehnică (RO)](wikis/documentatie_tehnica.md)
* [Componente Nerealizate (RO)](wikis/componente_nerealizate.txt)
