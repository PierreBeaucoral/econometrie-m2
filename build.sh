#!/usr/bin/env bash
# Construit le site : rend les decks, compile les fiches, copie les supports,
# fabrique les paquets à télécharger (paquets/), puis rend le site.
# Usage : ./build.sh            (depuis site_cours/)
set -euo pipefail
SITE="$(cd "$(dirname "$0")" && pwd)"
SRC="$SITE/../Seances Pierre"

# 1. Présentations
(cd "$SRC/S0_revision" && quarto render revision_TD1-3.qmd)
# Révision, TD4, TD5 : rendus localement, envoyés directement aux étudiants (non publiés)
for t in 4 5 6 7; do
  (cd "$SRC/TD$t/slides" && quarto render "TD${t}_slides.qmd")
done
cp "$SRC/TD6/slides/TD6_slides.html" "$SRC/TD7/slides/TD7_slides.html" "$SITE/slides/"

# 2. Énoncés (fiches 4-5 : supports d'origine ; 6-7 : compilés)
(cd "$SRC/fiches" && latexmk -pdf -quiet TD_etudiant_revision.tex TD_etudiant_seance_6.tex TD_etudiant_seance_7.tex Errata_seances_4_5.tex && latexmk -c -quiet)
cp "$SRC/../Cours chargé TD 1/TD4/TD_etudiant_seance_4.pdf" "$SITE/enonces/"
cp "$SRC/../Cours chargé TD 1/TD5/TD_etudiant_seance_5.pdf" "$SITE/enonces/"
cp "$SRC/fiches/TD_etudiant_revision.pdf" "$SRC/fiches/TD_etudiant_seance_6.pdf" "$SRC/fiches/TD_etudiant_seance_7.pdf" \
   "$SRC/fiches/Errata_seances_4_5.pdf" "$SITE/enonces/"

# 3. Paquets à télécharger (à déposer sur le site personnel ; URL dans _variables.yml)
PQ="$SITE/paquets"; rm -rf "${PQ:?}"; mkdir -p "$PQ"   # archives recréées à neuf
TMP="$(mktemp -d)"
for t in 4 5 6 7; do
  D="$TMP/TD$t"; mkdir -p "$D/04_Donnees"
  cp "$SRC/TD$t/04_Donnees/"*.dta "$D/04_Donnees/"
  cp "$SRC/TD$t/.here" "$SRC/TD$t/TD${t}_etudiant.do" "$SRC/TD$t/TD${t}_etudiant.R" "$D/"
  cp "$SITE/enonces/TD_etudiant_seance_$t.pdf" "$D/"
  [ "$t" -le 5 ] && cp "$SITE/enonces/Errata_seances_4_5.pdf" "$D/"
  (cd "$TMP" && zip -qr "$PQ/TD${t}_materiel.zip" "TD$t")
  (cd "$SRC/TD$t" && zip -q "$PQ/TD${t}_corrige.zip" "TD${t}_corrige.do" "TD${t}_corrige.R")
done
D="$TMP/S0_revision"; mkdir -p "$D"
cp -R "$SRC/S0_revision/etudiant/04_Donnees" "$D/"
cp "$SRC/S0_revision/etudiant/.here" "$SRC/S0_revision/etudiant/S0_etudiant.do" \
   "$SRC/S0_revision/etudiant/S0_etudiant.R" "$SITE/enonces/TD_etudiant_revision.pdf" "$D/"
(cd "$TMP" && zip -qr "$PQ/S0_revision.zip" S0_revision)
rm -rf "${TMP:?}"

# 3b. Téléchargements servis par le site : matériel étudiant toujours ; corrigé
#     seulement si la correction de la séance est publiée (draft: false)
TL="$SITE/telechargements"; mkdir -p "$TL"
cp "$PQ"/TD?_materiel.zip "$PQ/S0_revision.zip" "$TL/"
rm -f "$TL/TD4_corrige.zip" "$TL/TD5_corrige.zip"   # corrigés 4-5 : envoi direct
for t in 6 7; do
  if [ -f "$SITE/corrections/td$t.qmd" ] && grep -q '^draft: false' "$SITE/corrections/td$t.qmd"; then
    cp "$PQ/TD${t}_corrige.zip" "$TL/"
  else
    rm -f "$TL/TD${t}_corrige.zip"
  fi
done

# 4. Site
cd "$SITE" && quarto render
echo "Site rendu dans $SITE/_site ; paquets dans $PQ"
