#!/bin/bash

#| OS_ProjektniZadatak_2023              |#
#| Projekat: Simulacija Taxi sistema     |#
#| Predmet: Operativni sistemi           |#
#| Na projektu radio: Demir Halilbasic   |#
#| Student prve godine                   |#
#| Smijer informatika i racunarstvo      |#
#| Datum pocetka: 08.06.2023.            |#
#| Datum zavrsetka: 11.06.2023.          |#
#| Ukupan broj linija koda: 425          |#
#| IPI Akademija Tuzla                   |#

declare -A admin_credentials=(
  ["admin@example.com"]="admin"
)

declare -A user_credentials=(
  ["user@example.com"]="user"
)

taksi_vozila=(
  "Broj vozila: 1, Marka: Peugeot, Model: 307, Registarska oznaka: TA-123456, Status: Slobodno, Info: Nema"
  "Broj vozila: 2, Marka: Skoda, Model: Fabia, Registarska oznaka: TA-654321, Status: Zauzeto, Info: Nema"
)

declare -A rezervisane_voznje

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# =============== > PRIJAVA < =============== #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

function prijava {
  echo
  echo "~~ Dobrodosli u Login formu TAXI sistema ~~"
  echo " Za pocetak unesite Vase podatke za prijavu"
  echo
  read -p "Unesite email: " email
  read -s -p "Unesite sifru: " password
  echo

  if [[ -v admin_credentials[$email] && ${admin_credentials[$email]} == $password ]]; then
    clear
    echo "~~ Dobrodosli u TAXI sistem ~~"
    echo "[!] Uspjesno ste se ulogovali kao administrator."
    echo
    admin_strana
  elif [[ -v user_credentials[$email] && ${user_credentials[$email]} == $password ]]; then
    clear
    echo "~~ Dobrodosli u TAXI sistem ~~"
    echo "* Uspjesno ste se ulogovali na Vas nalog"
    echo
    korisnik_strana
  else
    clear
    echo "Pogresan email ili sifra. Molimo pokusajte ponovo."
    prijava
  fi
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# =============== > ADMIN STRANA < =============== #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

function admin_strana {
  echo "[Admin Menu] Odaberite opciju:"
  echo "1. Dodavanje novog taksi vozila"
  echo "2. Uredjivanje informacija o taksi vozilima"
  echo "3. Pregled informacija o voznjama"
  echo "4. Brisanje taksi vozila"
  echo "5. Logout"

  read -p "Unesite opciju: " opcija
  echo

  case $opcija in
    1) clear ; dodaj_vozilo ;;
    2) clear ; uredi_taksi_vozila ;;
    3) clear ; historija_voznji ;;
    4) clear ; obrisi_vozilo ;;
    5) clear ; logout ;;
    *) clear ; echo "Nepoznata opcija. Molimo pokusajte ponovo." ; clear ; admin_strana ;;
  esac
}

function dodaj_vozilo {
  echo "[A1] Dodavanje novog taxi vozila u sistem:"
  echo
  read -p "Unesite broj vozila: " broj_vozila
  read -p "Unesite marku vozila: " marka
  read -p "Unesite model vozila: " model
  read -p "Unesite registarsku oznaku: " registarska_oznaka
  read -p "Unesite status vozila (Slobodno/Zauzeto): " status

  novo_vozilo="Broj vozila: $broj_vozila, Marka: $marka, Model: $model, Registarska oznaka: $registarska_oznaka, Status: $status, Info: Nema"

  taksi_vozila+=("$novo_vozilo")

  clear
  echo "[Success] Novo taksi vozilo uspjesno dodato."
  echo

  admin_strana
}

function uredi_taksi_vozila {
  echo "[A2] Uredjivanje informacija o taksi vozilima:"
  echo

  echo "Dostupna taksi vozila:"
  for (( i=0; i<${#taksi_vozila[@]}; i++ )); do
    vozilo_index=$((i+1))
    echo "Vozilo $vozilo_index: ${taksi_vozila[$i]}"
  done
  echo

  read -p "Unesite redni broj vozila koje zelite urediti: " broj_vozila_uredi
  echo

  if [[ ! ${taksi_vozila[$broj_vozila_uredi - 1]} ]]; then
    clear
    echo "[Error] Taksi vozilo s rednim brojem $broj_vozila_uredi ne postoji."
    echo
    admin_strana
  fi

  echo "Odaberite opciju za uredjivanje taksi vozila $broj_vozila_uredi:"
  echo "1. Promjena statusa vozila (Slobodno/Zauzeto)"
  echo "2. Promjena registarske oznake"
  echo "3. Dodavanje informacija"
  echo "4. Odustani"

  read -p "Unesite opciju: " opcija_uredi
  echo

  case $opcija_uredi in
    1) promjena_statusa $broj_vozila_uredi ;;
    2) promjena_registarske_oznake $broj_vozila_uredi ;;
    3) dodaj_info $broj_vozila_uredi ;;
    4) clear ; admin_strana ;;
    *) clear ; echo "[Error] Nepoznata opcija. Molimo pokusajte ponovo." ; echo ; uredi_taksi_vozila ;;
  esac
}

function promjena_statusa {
  broj_vozila=$1

  trenutni_status=$(echo "${taksi_vozila[$broj_vozila - 1]}" | grep -oP '(?<=Status: )\w+')
  novi_status=""

  if [[ $trenutni_status == "Slobodno" ]]; then
    novi_status="Zauzeto"
  else
    novi_status="Slobodno"
  fi

  taksi_vozila[$broj_vozila - 1]=$(echo "${taksi_vozila[$broj_vozila - 1]}" | sed "s/Status: $trenutni_status/Status: $novi_status/")

  clear
  echo "[Success] Status taksi vozila $broj_vozila uspjesno promijenjen u $novi_status."
  echo

  admin_strana
}

function promjena_registarske_oznake {
  broj_vozila=$1

  read -p "Unesite novu registarsku oznaku za taksi vozilo $broj_vozila: " nova_registarska_oznaka
  echo

  taksi_vozila[$broj_vozila - 1]=$(echo "${taksi_vozila[$broj_vozila - 1]}" | sed "s/Registarska oznaka: [[:alnum:]-]*/Registarska oznaka: $nova_registarska_oznaka/")

  clear
  echo "[Success] Registarska oznaka taksi vozila $broj_vozila uspjesno promijenjena u $nova_registarska_oznaka."
  echo

  admin_strana
}

function dodaj_info {
  broj_vozila=$1

  read -p "Unesite nove informacije za taksi vozilo $broj_vozila: " nove_informacije
  echo

  taksi_vozila[$broj_vozila - 1]=$(echo "${taksi_vozila[$broj_vozila - 1]}" | sed "s/Info: .*/Info: $nove_informacije/")

  clear
  echo "[Success] Informacije za taksi vozilo $broj_vozila uspjesno dodane."
  echo

  admin_strana
}

function historija_voznji {
  echo "[A3] Pregled historije rezervisanih voznji svih korisnika:"
  echo

  if [[ ${#rezervisane_voznje[@]} -eq 0 ]]; then
    clear
    echo "Historija rezervisanih voznji prazna!"
  else
    for index in "${!rezervisane_voznje[@]}"; do
      #echo "Voznja $((index+1)):"
      echo "${rezervisane_voznje[$index]}"
    done
  fi

  echo
  admin_strana
}

function obrisi_vozilo {
  echo "[A4] Brisanje taksi vozila iz sistema"
  echo

  echo "Dostupna taksi vozila:"
  for ((i = 0; i < ${#taksi_vozila[@]}; i++)); do
    echo "$(($i + 1)). ${taksi_vozila[$i]}"
  done

  echo

  read -p "Unesite redni broj vozila kojeg zelite obrisati: " broj_vozila
  echo

  if [[ ! ${taksi_vozila[$broj_vozila - 1]} ]]; then
    clear
    echo "[Error] Taksi vozilo pod rednim brojem $broj_vozila ne postoji."
    echo
    admin_strana
  fi

  unset "taksi_vozila[$broj_vozila - 1]"

  taksi_vozila=("${taksi_vozila[@]}")

  clear
  echo "[Success] Taksi vozilo $broj_vozila uspjesno obrisano."
  echo

  admin_strana
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# =============== > KORISNIK STRANA < =============== #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

function korisnik_strana {
  echo "[Korisnik Menu] Odaberite opciju:"
  echo "1. Rezervacija taksi vozila"
  echo "2. Pregled informacija o voznjama"
  echo "3. Logout"

  read -p "Unesite opciju: " opcija
  echo

  case $opcija in
    1) clear ; rezervacija_taksi ;;
    2) clear ; pregled_voznji ;;
    3) clear ; logout ;;
    *) clear ; echo "[Error] Nepoznata opcija. Molimo pokusajte ponovo." ; echo ; korisnik_strana ;;
  esac
}

function rezervacija_taksi {
  echo "[~] Rezervacija taksi vozila:"
  echo
  read -p "Unesite polaziste: " polaziste
  read -p "Unesite odrediste: " odrediste
  read -p "Unesite vrijeme: " vrijeme

  if [[ $vrijeme -lt 0 || $vrijeme -gt 23 ]]; then
    clear
    echo "[Error] Vremenski okvir nije validan. Molimo pokusajte ponovo."
    echo "Rezervacije obuhvataju vremenski okvir od 0 do 23 sata!"
    echo "NAPOMENA: Nocna tarifa (22h-5h) naplacuje se sa dodatnih 20 % na ukupnu cijenu rezervacije."
    echo
    rezervacija_taksi
  fi

  read -p "Unesite broj putnika: " broj_putnika

  if [[ $broj_putnika -lt 1 || $broj_putnika -gt 4 ]]; then
    clear
    echo "[Error] Broj putnika nije validan. Molimo pokusajte ponovo."
    echo
    rezervacija_taksi
  fi

  echo

  echo "Dostupna taksi vozila:"
  for (( i=0; i<${#taksi_vozila[@]}; i++ )); do
    vozilo_index=$((i+1))
    echo "Vozilo $vozilo_index: ${taksi_vozila[$i]}"
  done
  echo

  read -p "Unesite zeljeno taksi vozilo (ili kucajte 'odustani' za povratak): " zeljeno_vozilo
  echo

  if [[ $zeljeno_vozilo == "odustani" ]]; then
    clear
    echo "Rezervacija taksi voznje je otkazana."
    echo
    korisnik_strana
  fi

  rezervacija_index=$((zeljeno_vozilo-1))
  if [[ $rezervacija_index -lt 0 || $rezervacija_index -ge ${#taksi_vozila[@]} ]]; then
    clear
    echo "[Error] Uneseno taksi vozilo ne postoji. Molimo pokusajte ponovo."
    echo
    rezervacija_taksi
  fi

  status=$(echo "${taksi_vozila[$rezervacija_index]}" | grep -oP '(?<=Status: )\w+')
  if [[ $status == "Slobodno" ]]; then
    cijena=$((RANDOM % 61 + 10))
    iznos=$((cijena * broj_putnika))
    nocna_provjera=0
    if [[ $vrijeme -lt 6 ]]; then
      nocna_provjera=1
    elif [[ $vrijeme -gt 21 ]]; then
      nocna_provjera=1
    fi
    if [[ $broj_putnika -gt 1 ]]; then
      echo "Cijena jedinicne voznje od $polaziste do $odrediste iznosi $cijena KM."
      if [[ nocna_provjera -eq 1 ]]; then
        echo "NAPOMENA: Vasa voznja pripada nocnom vremenskom intervalu (22h-5h), stoga se primjenjuje dodatnih 20 % na ukupnu cijenu"
        cijena=$((cijena * 12 / 10))
        iznos=$((iznos * 12 / 10))
        echo "NOVA CIJENA iznosi $cijena KM (jedinicna rezervacija)."
      fi
      echo "NAPOMENA: Posto rezervacija zahtijeva $broj_putnika putnika, Vasa ukupna cijena rezervacije iznosi $iznos KM."
      echo "Da li pristajete na TAXI voznju? (da/ne)"
    else
      if [[ nocna_provjera -eq 1 ]]; then
        echo "NAPOMENA: Vasa voznja pripada nocnom vremenskom intervalu (22h-5h), stoga se primjenjuje dodatnih 20 % na ukupnu cijenu"
        echo "STARA CIJENA iznosi $iznos KM (jedinicna rezervacija)."
        iznos=$((iznos * 12 / 10))
      fi
      echo "Cijena voznje za jednu osobu od $polaziste do $odrediste iznosi $iznos KM. Da li pristajete na TAXI voznju? (da/ne)"
    fi
    read -p "> " pristanak

    while [ $pristanak != "da" ] && [ $pristanak != "ne" ]; do
      echo
      echo "[Error] Unos nije validan. Molimo koristite naredbe da ili ne."
      read -p "> " pristanak
    done

    if [[ $pristanak == "ne" ]]; then
      clear
      echo "Rezervacija taksi voznje je otkazana."
      echo
      korisnik_strana
    fi

    novo_vozilo=$(echo "${taksi_vozila[$rezervacija_index]}" | sed 's/Slobodno/Zauzeto/')
    taksi_vozila[$rezervacija_index]=$novo_vozilo

    marka_model=$(echo "${taksi_vozila[$rezervacija_index]}" | grep -oP '(?<=Marka: ).+(?=, Model: )')
    model=$(echo "${taksi_vozila[$rezervacija_index]}" | grep -oP '(?<=Model: ).+(?=, Registarska oznaka: )')

    rezervisana_voznja="Broj vozila: $zeljeno_vozilo | Polaziste: $polaziste | Odrediste: $odrediste | Marka i Model vozila: $marka_model $model | Vrijeme polaska: $vrijeme sata/i | Broj putnika: $broj_putnika | Cijena: $iznos KM"
    rezervisane_voznje+=["$rezervisana_voznja"]

    clear
    echo "[Success] Taksi vozilo $zeljeno_vozilo je uspjesno rezervisano."
    echo
    korisnik_strana
  else
    clear
    echo "[Error] Odabrano vozilo je zauzeto. Molimo odaberite neko od slobodnih vozila."
    echo
    rezervacija_taksi
  fi
}

function pregled_voznji {
  echo "[~] Pregled rezervisanih voznji:"
  echo

  if [[ ${#rezervisane_voznje[@]} -eq 0 ]]; then
    clear
    echo "Nema rezervisanih voznji!"
  else
    for index in "${!rezervisane_voznje[@]}"; do
      #echo "[Voznja $((index+1))]"
      echo "${rezervisane_voznje[$index]}"
    done
  fi

  echo
  korisnik_strana
}

function logout {
  echo "~~ Hvala Vam na koristenju TAXI sistema ~~"
  echo

  read -p "Da li se zelite ponovo prijaviti? (da/ne): " odgovor
  echo

  if [[ $odgovor == "da" ]]; then
    clear
    prijava
  elif [[ $odgovor == "ne" ]]; then
    exit 0
  else
    clear
    echo "Nepoznata opcija. Molimo pokusajte ponovo."
    echo
    logout
  fi
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# =============== > POCETAK SKRIPTE < =============== #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

prijava