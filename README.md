# Site des TD d'économétrie (Magistère 3)

## Construire
```bash
./build.sh            # rend les decks, compile les fiches, fabrique paquets/, rend le site
quarto preview        # aperçu local
```
Sources : `../Seances Pierre/` (decks, fiches, corrigés Stata et R, données).

## Paquets à télécharger
`build.sh` produit `paquets/` (non versionné) :
- `TDx_materiel.zip` : données, do-file et script R étudiants, énoncé (à publier avant la séance) ;
- `TDx_corrige.zip` : corrigés Stata et R (à publier après la séance) ;
- `S0_revision.zip` : données et do-file des compléments de la séance de révision.

Le matériel étudiant est copié dans `telechargements/` et servi par le site ; les corrigés y sont copiés seulement une fois la correction publiée. Adresse dans `_variables.yml`.

## Publier une correction après la séance
Séances 6 et 7 uniquement. Révision, TD4 et TD5 (sujets d'Ibrahim Goni Abdoulkadiri) : diapositives et corrections envoyées directement aux étudiants, jamais publiées ; sources des corrections dans `../Seances Pierre/corrections_envoi_direct/`.

Dans `corrections/tdX.qmd`, passer `draft: true` à `draft: false`, puis `./build.sh` (copie aussi `TDX_corrige.zip`) et `quarto publish gh-pages --no-prompt`.
Les sources `corrections/` ne sont pas versionnées (dépôt public) : les sauvegarder localement.

## Publier
```bash
./build.sh
git add -A && git commit -m "..." && git push
quarto publish gh-pages --no-prompt
```
`site-url` dans `_quarto.yml` suppose l'adresse https://pierrebeaucoral.github.io/econometrie-m2/.
