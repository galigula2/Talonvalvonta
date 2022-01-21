# Talonvalvontaprojekti

Järjestelmän ytimenä toimii RasberryPI 4 Model B korttitietokone joka asennetaan tekniseen tilaan sopivasti toimilaitteiden ja verkkokaapin läheisyyteen. Raspilla ajetaan työkuormia Docker-konteissa jolloin eri osat pysyvät hyvin erillään toisistaan.

 Grafanan UI julkaistaan reitittimen läpi internettiin DynDNS tai vastaavan avulla --> myös kotiverkosta pääsee kätevästi katsomaan käyriä. Järjestelmä seuraa talon eri osia ja sieltä on mahdollista lähettää myös hälytyksiä tiettyjen raja-arvojen ylittyessä.

![Overall picture](/diagrams/Talonvalvonta.png)

## Next steps (Korkean tason TODO't)
- YLEISET
  - docker-kansion alle README joka selittää mm. data-kansion tarkoituksen
  - PortForwardin tekeminen reitittimen läpi (vai muu systeemi? tutkitaan voiko grafanan dashboardit uploadata jonnekin näkyville)
    - Tässä vaiheessa voisi riittää vain [Dashboardin snapshotin publishaaminen](https://grafana.com/docs/grafana/latest/sharing/share-dashboard/#publish-a-snapshot)
    - Eri juttu sitten jos halutaan jotain laajempaa kotiautomaatiota tai kameroita tarjota
  - Tietokannan varmuuskopioinnin valmistelu
  - Network/Docker watchdog käynnistämään uudestaan tarvittaessa ([ohjeet](https://www.meazurem.com/blog/raspberry-pi-with-network-watchdog/))
  - Perustason alerit (esim. CPU Temp)
  - Alert notifier autoprovisioitumaan (setupattu ohjeiden mukaan, mutta https://community.grafana.com/t/provisioning-contact-points/56281/3)
- RUUVI
  - Saunan ruuvitagille puinen kotelo (printattu pehmenee liikaa)
  - Retentiopolicyn ja downsamplaaminen suunnittelu, mitä oikeastaan halutaan?
  - Alerttien konffaaminen
- SÄHKÖMITTAUS
  - Sähkömittauksen tallennuksen suunnittelu (hetkellinen power live streaminä grafanaan, 15 tai 60min kulutuslukemat influxdb:hen, konfiguraatiofilestä luku)
  - Ratkaisun kontitus ja käyttöönotto
  - Dashboardi tunti- tai minuuttitasoan kulutuksen seurantaan sekä reaaliaikakulutus ylös
  - Retentiopolicyn ja downsamplaaminen suunnittelu, mitä oikeastaan halutaan?
  - Alerttien konffaaminen
- LÄMMÖNVAIHDIN
  - Osahankinnat ja kaapelin valmistus
  - Kaapelin kytkeminen Oumaniin
  - Retentiopolicyn ja downsamplaaminen suunnittelu, mitä oikeastaan halutaan?
  - TaloLoggerin valmistelu ja käyttöönotto
  - Alerttien konffaaminen (mitä tulee suoraan Oumanilta?)

# Rasp berry PI 4 Model B

[Technical Documentation](https://www.raspberrypi.com/documentation/)
[Vinkkejä viilentämiseen](https://www.freva.com/placing-heatsinks-on-the-raspberry-pi-4/)

## Speksit

Komponentti | Tiedot
-|-
Processor	| Broadcom BCM2711, quad-core Cortex-A72 (ARM v8)<br>64-bit SoC @ 1.5GHz
Memory | 	4GB LPDDR4 SDRAM
Connectivity | 2.4 GHz and 5.0 GHz IEEE 802.11b/g/n/ac wireless<br>LAN, Bluetooth 5.0, BLE<br>Gigabit Ethernet<br>2 × USB 3.0 ports<br> 2 × USB 2.0 ports.
GPIO | Standard 40-pin GPIO header<br>(fully backwards-compatible with previous boards)
Video & Sound	| 2 × micro HDMI ports (up to 4Kp60 supported)<br>2-lane MIPI DSI display port<br>2-lane MIPI CSI camera port<br>4-pole stereo audio and composite video port
Multimedia | H.265 (4Kp60 decode)<br>H.264 (1080p60 decode, 1080p30 encode)<br>OpenGL ES, 3.0 graphics
SD card support	| Micro SD card slot for loading operating system and data storage (64GB)
Input Power	| 5V DC via USB-C connector
Production lifetime | 	The Raspberry Pi 4 Model B will remain in production until at least January 2026.

## GPIO Pinnit
Raspberryssä on 40 kpl ohjelmoitavia GPIO-pinnejä. Pinnien nimet ja asema laudalla on esitetty kuvassa alla. 

![GPIOPins](/diagrams/GPIOPins.png)

Alla olevat ohjeet käyttävät pinneille tässä kuvassa näkyviä nimiä.

Linkkejä
- [Parempi interaktiivinen ohje](https://pinout.xyz/)
- [GPIO pins info and examples](https://projects.raspberrypi.org/en/projects/physical-computing/1)
- [Reading Analogue Sensors With One GPIO pin](https://www.raspberrypi-spy.co.uk/2012/08/reading-analogue-sensors-with-one-gpio-pin/)

## Perusasetukset
- Asennetaan `Raspberry Pi OS Lite 64 bit`
  - HUOM! 64 bittinen versio on tarpeen mm. InfluxDB:n takia (heiltä löytyy vain ARM64-docker imaget)
  - Ladataan viimeisin 64bit Lite image: https://downloads.raspberrypi.org/raspios_lite_arm64/images/
  - Asennetaan Raspberry Imager-sovellus ja valitaan Custom-distro ja ladattu .img-tiedosto
  - Tämä myös alustaa 64Gb muistikortin FATR32:lla jolta Rasberry osaa bootata
- Lataamisen jälkeen [enabloidaan headless imageen wifi-yhdistäminen js SSH-tuki](https://medium.com/@nikosmouroutis/how-to-setup-your-raspberry-pi-and-connect-to-it-through-ssh-and-your-local-wifi-ac53d3839be9)
  - Luodaan boot-partitiolle tyhjä `ssh` niminen tyhjä tiedosto joka enabloi SSH:n käynnistyksen yhteydessä
  - Luodaan boot-partitiolle `wpa_supplicant.conf` niminen tiedosto joka kertoo mihin WIFI-verkkoon otetaan automaattisesti yhteyttä (sisältö esim [täältä](https://medium.com/@nikosmouroutis/how-to-setup-your-raspberry-pi-and-connect-to-it-through-ssh-and-your-local-wifi-ac53d3839be9))
    - Huom! Tässä voi määrittää useamman wifi-verkon ja niille priority-asetuken (korkeampi luku valitaan ensin).
    - Kätevää jos on poissa pääverkon kuuluvilta ja pitää saada yhteys raspbiin. Puhelimen Wifi Hotspot-näytöstä voi tarkistaa osoitteen minkä Raspi saa jaetussa verkossa.
  - Windowsilla saattaa joutua laittamaan FAT32 boot-partitiolle drive letter jotta sinne pääsi käsiksi ja luomaan tarvittavat tiedostot
  - WIFI voitaisiin laittaa yhdistämään tietoturvasyistä erilliseen IoT-verkkoon, mutta nykyisen reitittimen rajoitusten takia näin ei tehty (lisäksi jatkossa käytetään kuitenkin langalista verkkoa jolloin tämän merkitys pienenee)
- Asetetaan kiinteä IP reitittimen asetuksissa, esim `192.168.1.120`
- Käynnistetään Rasbi ja koitetaan ottaa yhteyttä
  - SSH-yhteys laitteeseen `ssh ip@192.168.1.120`, salasana `raspberry`
    - NOTE: As discussed [here](https://www.reddit.com/r/raspberry_pi/comments/hckfiv/can_you_explain_this_mystery_sshing_to_my_pi_4/) power management on the connecting side can cause SSH to hang after giving SSH password. On an ASUS Gaming laptop this meant that SSH was not working if the power cable was not plugged in (mostl likely this is only when in WIFI)
  - Vaihdetaan oletussalasana toiseksi `passwd`-komennolla
  - Ajetaan peruspäivitykset `sudo raspi-config`-sovelluksella
- Kun asetukset valmiina voidaan siirtää Raspi tekniseen tilaan 
  
- Asennetaan Docker ja Docker Compose alustaksi
  - https://blog.anoff.io/2020-12-install-docker-raspi/
  - Lataa asennusskripti `curl -fsSL https://get.docker.com -o get-docker.sh`
  - Ahja asennusskripti `sh get-docker.sh`
  - Lisää käyttäjä 'pi' docker-ryhmään jotta kontteja saadaan ajettua `sudo usermod -aG docker $(whoami)`
  - Katkaise yhteys ja kirjaudu uudestaan SSH:lla (tämä lataa käyttäjän uuden ryhmän)
  - Kokeile että Docker toimii `docker run hello-world`
  - Asenna Docker Compose (Asentaa myös Python 3.x)
    - `sudo apt-get -y install libffi-dev libssl-dev python3-dev python3 python3-pip` 
    - `sudo pip3 install docker-compose` needs sudo to put it into path correctly

- Asennetaan Git ja ladataan tämä repository
  - Asenna git `sudo apt-get install git`
  - Luodaan ssh-avain `ssh-keygen` (oletusvalinnat ok, lisää salasana jos näet tarpeelliseksi)
  - Lisätään ssh-avain GitHub käyttäjäsi avaimiin [täältä](https://github.com/settings/ssh/new)
  - Kloonaa repository `git clone git@github.com:galigula2/Talonvalvonta.git`
  - Lataa submodulet komennolla `git submodule update --init` 

- Viimeistelytoimenpiteitä
  - Lisää `ll` tiedostolistauksia varten `sed -i 's/#*alias ll=.*$/alias ll="ls -ahl"/g' ~/.bashrc`
  - Varmista, että koko muistikortti on käytettävissä `sudo raspi-config --expand-rootfs`
  - TODO: https://blog.anoff.io/2020-12-instal
  - TODO: docker-raspi/#enable-automatic-upgrades ?
  - TODO: https://blog.anoff.io/2020-12-install-docker-raspi/#set-default-locale ?
  - TODO: https://blog.anoff.io/2020-12-install-docker-raspi/#disable-wifibluetooth (if not needed?)
 
## Ohjelmistot
Ohjelmistot on hyvä asentaa ja ottaa käyttöön tässä järjestyksessä. Pääkoneella pyörii näistä kaikki ja mahdollisilla sivukoneilla ainakin Telegraf. Näin saadaan hyvä pohja erilaisten mittaussovellusten ajamiselle. 

### InfluxDB
- Aikasarjatietokanta mittatulosten tallentamiseen + telegraf järjestelmän metriikoiden hakemiseen  
- Perustuu https://blog.anoff.io/2020-12-run-influx-on-raspi-docker-compose/ mutta tarvittavat kansiot ja kooditiedostot luodaan repossa olevilla tiedostoilla
- Käyttöönotto
  - Tarkista, että `.sh`-tiedostoilla kansiossa `Talonvalvonta/docker/ìnfluxdb/init` on suoritusoikeudet (x)
  - Kopioi secrets-template kansiossa `Talonvalvonta/docker/compose-files/influxdb` tiedosto `secrets.env.template` tiedostoksi `.env` ja täytä salasana käyttäjälle
  - Käynnistä palvelut (ensimmäisellä kerralla, jatkossa pitäisi käynnistyä Raspin käynnistyessä)
    - Mene hakemistoon `Talonvalvonta/docker/compose-files/influxdb/`
    - Aja `docker-compose up -d` joka käynnistää palvelut "detached"-moodissa
    - Tarkista, että `influxdb` palvelu käynnistyi ajamalla `docker ps` ja katso, että se pysyy pystyssä
- Käyttäminen
  - Käytä komentorivityökalua Raspin sisältä esim. 
    - `docker exec -it influxdb influx org list`
    - `docker exec -it influxdb influx bucket list`
    - `docker exec -it influxdb influx user list`
  - Käytä Graafista käyttöliittymää Raspin ulkopuolelta
    - Avaa selaimella `localhost:8086`
    - Kirjaudu sisällä InfluxDB-tunnuksilla
- TODO: Varmuuskopiot
  - Mihin varmuuskopioidaan? Pilveen vai NAS:lle? Miten usein?
  - https://docs.influxdata.com/influxdb/v2.1/backup-restore/backup/
- TODO: Data retention policy määrittely
  - Real time data vs history data, InfluxDB:ssä kerrotaan suoraan kauanko data säilytetään, tarvitaan ehkä downsamplattu taulu pitkäaikaissäilytykseen
  - https://docs.influxdata.com/influxdb/v2.1/process-data/common-tasks/downsample-data/

### Telegraf
- Telegraf kerää tietoja Raspin CPU-kuorasta ja muista metriikoista ja tallentaa ne InfluxDB:hen
- Esimerkeissä deployattu yleensä influxdb:n kanssa samassa, mutta Influxdb2 tokeneita ei saa ohjelmallisesti luotua käynnistyksen yhteydessä kätevästi --> tehdään erilllään. Lisähyötynä nämä saa helposti erillisiin koneisiin talteen.
- Käyttönotto
  - Listaa tokenit komennolla `docker exec -it influxdb influx auth list` ja kopioi Telegraf-tokenin arvo (3. sarake) talteen
  - Kopioi secrets-template kansiossa `Talonvalvonta/docker/compose-files/telegraf` tiedosto `secrets.env.template` tiedostoksi `.env` ja täytä token äsken kopioidulla arvolla + anna nimi tälle instanssille
  - Käynnistä palvelut (ensimmäisellä kerralla, jatkossa pitäisi käynnistyä Raspin käynnistyessä)
    - Mene hakemistoon `Talonvalvonta/docker/compose-files/telegraf/`
    - Aja `docker-compose up -d` joka käynnistää palvelut "detached"-moodissa
    - Tarkista, että `telegraf` palvelu käynnistyi ajamalla `docker ps` ja katso, että se pysyy pystyssä
    - Tarkista Influxdb-UI:sta, että dataa tulee sisälle

### Grafana
- Visualisointityöalu aikasarjadatalle
- Perustuu https://blog.anoff.io/2021-01-howto-grafana-on-raspi/ mutta tarvittavat kansiot ja kooditiedostot luodaan repossa olevilla tiedostoilla
- Valmistele Discord-webhookki [näillä ohjeilla](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)
- Listaa tokenit komennolla `docker exec -it influxdb influx auth list` ja kopioi Grafana -tokenin arvo (3. sarake) talteen
  - Kopioi secrets-template kansiossa `Talonvalvonta/docker/compose-files/grafana` tiedosto `secrets.env.template` tiedostoksi `.env` ja täytä token äsken kopioidulla arvolla ja Discord webhook urlilla
  - Käynnistä palvelut (ensimmäisellä kerralla, jatkossa pitäisi käynnistyä Raspin käynnistyessä)
    - Mene hakemistoon `Talonvalvonta/docker/compose-files/grafana/`
    - Aja `docker-compose up -d` joka käynnistää palvelut "detached"-moodissa
    - Tarkista, että `grafana` palvelu käynnistyi ajamalla `docker ps` ja katso, että se pysyy pystyssä
- Käyttäminen
  - Kun kontti on ajossa siihen voi ottaa suoraan yhteyttä selaimella `192.168.1.120:3000`
  - Admin-käyttö vaatii aikaisemmin asetetun salasanan
- Dashoboardit
  - TODO: Reaaliaikadashboard jonne streamataan 5s välein tietoa esim. sähkönkulutus juuri tällä hetkellä? (Vai riittääkö downsamplauksella kikkailu? kiinnostaako tiukka tahti graafina?)
     - Olisko tämä data siltikin provider?
  - Perusdashboardi on määritelty `Talonvalvonta/docker/grafana/dashboards/perusnaytto.json` ja muutokset olisi hyvä tallentaa sinne esim. kun tulee uusia mittauksia

# Mittaukset

## RuuviTag (Huonelämpötilat, -kosteudet- ilmanpaineet)
- Insipiraatio: https://medium.com/@ville.alatalo/oma-s%C3%A4%C3%A4asema-ruuvitagilla-ja-grafanalla-25c823f20a20
  - Erotuksena tähän, uudet RuuviTagit lähettävät automaattisesti RAWv2-formaattia -> koteloita ei tarvitse avata
  - Jokaisen huonetermostaatin yhteyteen oma RuuviTag + muutama muu huone missä ei ole termostaattia (esim. kodinhoito)
- Käytetään RuuviCollector-apuohjelmaa (https://github.com/Scrin/RuuviCollector)
  - Ajetaan Dockerin sisällä managementin helpottamiseksi
  - Kirjoitetaan InfluxDB:hen [V1 Compatibility API](https://docs.influxdata.com/influxdb/v2.1/reference/api/influxdb-1x):a hyödyntäen
- Käyttöönotto
  - Asete salasana automaattisesti luodulle ruuvi-writer-käyttäjälle komennolla `docker exec -it influxdb influx v1 auth set-password --username ruuvi-writer --password <RuuviWriterPasswordToSet>`
  - Valmistele Docker-paketti paikallisesti
    - Mene kansioon `Talonvalvonta/src/RuuviCollector`
    - Luo Docker-paketti komennolla `docker build -t ruuvi-collector .`
    - Tähän ei pitäisi juuri joutua koskemaan ellei RuuviCollectorista tule uutta versiota
  - Sääsä asetukset
    - Kopioi kansiossa `Talonvalvonta/docker/RuuviCollector` löytyvät `ruuvi-collector.properties.template` ja `ruuvi-names.properties.template` tiedostot samaan kansioon ilman `.template`-päätteitä
    - Muokkaa `Talonvalvonta/src/RuuviCollector/ruuvi-collector.properties` tiedostoa
      - `influxPassword=<RuuviWriterPasswordToSet>` (Salasana sama kuin minkä asetit yllä)
    - Muokkaa `Talonvalvonta/src/RuuviCollector/ruuvi-names.properties` tiedostoa
      - Listaa tänne kaikki ne ruuvitagit joiden dataa olet lukemassa
      - Formaatti on `MAC-osoite`=`Nimi` (Saa olla ääkkösiä ja välilyöntejä)
  - Käynnistä palvelut (ensimmäisellä kerralla, jatkossa pitäisi käynnistyä Raspin käynnistyessä)
    - Mene hakemistoon `Talonvalvonta/docker/compose-files/RuuviCollector/`
    - Aja `docker-compose up -d` joka käynnistää palvelut "detached"-moodissa
    - Tarkista, että `ruuvi-collector` palvelu käynnistyi ajamalla `docker ps` ja katso, että se pysyy pystyssä
- Sopiva 3D-printattava wallmount löytyy [Thingiversestä](https://www.thingiverse.com/thing:3535838)
- Ruuvi Pro:t pystyvät kuuntelemaan myös ulkopuolista anturia
  - Tässä olisi mahdollista tehdä talon sisällä termostaatitarkkailua, mutta voi mennä säätämiseksi

## Sähkönkulutus LED-indikaattorista
- Perusajatus täältä: https://hyotynen.iki.fi/kotiautomaatio/sahkonkulutuksen-seurantaa/
- Käyttöönotto
  - Tilaa [LM393-Valosensorimoduuli](https://www.elektroniikkaosat.com/c-67/p-163360505/Valosensorimoduuli-fotodiodi.html) joka antaa digitaalisen ulostulon
  - Rakenna teline joka pitää sensorin sähkömittarin LED:n kohdalla ja suojaa fotodiodia turhalta valolta
  - Kytketään tämä suoraan Raspbin GPIO-pinneihin 
    - VCC -> 3.3V
    - GND -> GND
    - DO -> GPIO24
    - Säädä sensorimoduulin herkkyys potikasta niin, että moduulin led välkkyy sähkömittarin ledin tahdissa (tarkista, että toimii valot päällä ja pois!)
  - Haetaan sopivat parametrit ajamalla `python3 test/electricity.py` laitteella ja varmistamalla, että mittausvälin aikana luetut pulssit LED:n välähdyksiä. 
    - Parametrit säädetään suoraan scriptin sisältä.
    - `BCM_CHANNEL`: Mistä kanavasta signaali luetaan (Tässä käytetään GPIO24:sta niin arvoksi tulee `24`)
    - `RECORDING_INTERVAL_SECONDS`: Mittausikkunan pituus sekunteissa. Esim `5`
    - `PULSES_PER_KWH`: Sähkömittarin kyljestä luetu arvo kuinka monta pulssia vastaa yhtä kilowattituntia. Itsellä oli `10000` 
    - `BOUNCE_MS`: Huomioidaan digitaalisignaalin huojunta tilan vaihtuessa laittamalla minimiväli signaaleille millisekunneissa. Sopiva arvo löytyy kokeilemalla, mutta itsellä >=3ms arvot näyttivät toimivan. Laitoin arvoksi `5` varmuuden vuoksi joka pitäisi olla riittävän pieni kaikille tarvittaville kulutuslukemille (5ms maksimiväli tarkoittaa itsellä n.71kW maksimi mitattavaa kulutusta mikä ei pitäisi koskaan tulla vastaan)
  - Käynnistä palvelut (ensimmäisellä kerralla, jatkossa pitäisi käynnistyä Raspin käynnistyessä)
    - TODO: Ohjeet kopioida parametrit ja käynnistää docker-kontti

## Lämmönvaihtimen data (vesien lämpötilat, ulkolämpötila)
- https://medium.com/@ville.alatalo/diy-omakotitalon-l%C3%A4mmityksen-mittaaminen-ja-visualisointi-cacfcd974a44
- https://olammi.iki.fi/sw/taloLogger/ (Python 2.4+)
- https://github.com/alatalo/ouman-collector (Python 2.7)
- TODO: Selvitä mitä takuulle tapahtuu jos laitteen kuoren avaa ja kytkee sarjaporttiliittimen

## Swegon Casa R120 (???)

## Tuleva ilmalämpöpumppu (???)
- Mitsibishin pumpuissa on MELCloud jolla saadaan tietoa ulos pumpusta. Sitä voi tutkia esim tällä https://github.com/vilppuvuorinen/pymelcloud
- Keinoja löytyy myös tutkia asiaa suoraan pumpulta mutta vaatii temppuiluja https://chrdavis.github.io/hacking-a-mitsubishi-heat-pump-Part-1/
- Mm. Gree:lle on tehty myös temppuja suoraan kaukosäätimen asetuksia reverse-engineeraamalla https://www.dudley.nu/projects/heatpump-control/
