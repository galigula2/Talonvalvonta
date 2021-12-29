# Talonvalvontaprojekti

Järjestelmän ytimenä toimii RasberryPI 4 Model B korttitietokone joka asennetaan tekniseen tilaan sopivasti toimilaitteiden ja verkkokaapin läheisyyteen. Raspilla ajetaan työkuormia Docker-konteissa jolloin eri osat pysyvät hyvin erillään toisistaan.

 Grafanan UI julkaistaan reitittimen läpi internettiin DynDNS tai vastaavan avulla --> myös kotiverkosta pääsee kätevästi katsomaan käyriä.

![Overall picture](/diagrams/Talonvalvonta.png)


# Rasberry PI 4 Model B

[Technical Documentation](https://www.raspberrypi.com/documentation/)

## Speksit

Komponentti | Tiedot
-|-
Processor	| Broadcom BCM2711, quad-core Cortex-A72 (ARM v8)<br>64-bit SoC @ 1.5GHz
Memory | 	4GB LPDDR4 SDRAM
Connectivity | 2.4 GHz and 5.0 GHz IEEE 802.11b/g/n/ac wireless<br>LAN, Bluetooth 5.0, BLE<br>Gigabit Ethernet<br>2 × USB 3.0 ports<br> 2 × USB 2.0 ports.
GPIO | Standard 40-pin GPIO header<br>(fully backwards-compatible with previous boards)<br>[GPIO pins info and examples](https://projects.raspberrypi.org/en/projects/physical-computing/1)<br>[Reading Analogue Sensors With One GPIO pin](https://www.raspberrypi-spy.co.uk/2012/08/reading-analogue-sensors-with-one-gpio-pin/)
Video & Sound	| 2 × micro HDMI ports (up to 4Kp60 supported)<br>2-lane MIPI DSI display port<br>2-lane MIPI CSI camera port<br>4-pole stereo audio and composite video port
Multimedia | H.265 (4Kp60 decode)<br>H.264 (1080p60 decode, 1080p30 encode)<br>OpenGL ES, 3.0 graphics
SD card support	| Micro SD card slot for loading operating system and data storage (64GB)
Input Power	| 5V DC via USB-C connector
Production lifetime | 	The Raspberry Pi 4 Model B will remain in production until at least January 2026.

## Perusasetukset
- Asennetaan `Raspberry Pi OS Lite 64 bit`
  - HUOM! 64 bittinen versio on tarpeen mm. InfluxDB:n takia (heiltä löytyy vain ARM64-docker imaget)
  - Ladataan viimeisin 64bit Lite image: https://downloads.raspberrypi.org/raspios_lite_arm64/images/
  - Asennetaan Raspberry Imager-sovellus ja valitaan Custom-distro ja ladattu .img-tiedosto
  - Tämä myös alustaa 64Gb muistikortin FATR32:lla jolta Rasberry osaa bootata
- Lataamisen jälkeen [enabloidaan headless imageen wifi-yhdistäminen js SSH-tuki](https://medium.com/@nikosmouroutis/how-to-setup-your-raspberry-pi-and-connect-to-it-through-ssh-and-your-local-wifi-ac53d3839be9)
  - Luodaan boot-partitiolle tyhjä `ssh` niminen tyhjä tiedosto joka enabloi SSH:n käynnistyksen yhteydessä
  - Luodaan boot-partitiolle `wpa_supplicant.conf` niminen tiedosto joka kertoo mihin WIFI-verkkoon otetaan automaattisesti yhteyttä (sisältö esim [täältä](https://medium.com/@nikosmouroutis/how-to-setup-your-raspberry-pi-and-connect-to-it-through-ssh-and-your-local-wifi-ac53d3839be9))
  - Windowsilla saattaa joutua laittamaan FAT32 boot-partitiolle drive letter jotta sinne pääsi käsiksi ja luomaan tarvittavat tiedostot
  - WIFI voitaisiin laittaa yhdistämään tietoturvasyistä erilliseen IoT-verkkoon, mutta nykyisen reitittimen rajoitusten takia näin ei tehty (lisäksi jatkossa käytetään kuitenkin langalista verkkoa jolloin tämän merkitys pienenee)
- Asetetaan kiinteä IP reitittimen asetuksissa, esim `192.168.1.120`
- Käynnistetään Rasbi ja koitetaan ottaa yhteyttä
  - SSH-yhteys laitteeseen `ssh ip@192.168.1.120`, salasana `raspberry`
    - NOTE: As discussed [here](https://www.reddit.com/r/raspberry_pi/comments/hckfiv/can_you_explain_this_mystery_sshing_to_my_pi_4/) power management on the connecting side can cause SSH to hang after giving SSH password. On an ASUS Gaming laptop this meant that SSH was not working if the power cable was not plugged in (mostl likely this is only when in WIFI)
  - Vaihdetaan oletussalasana toiseksi `passwd`-komennolla
  - Ajetaan peruspäivitykset `sudo raspi-config`-sovelluksella
  
- Asennetaan K3s alustaksi
  - Rancherin ohjeet asentamiseen: https://rancher.com/docs/k3s/latest/en/quick-start/
  - Käytännössä vaatii vähän ylimääräistä säätöä jotta toimii Raspilla
    - Lisää `cgroup_memory=1 cgroup_enable=memory` mukaan `/boot/cmdline.txt`-tiedostoon
    - Ajetaan `curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644`
    - Jos klusterin käynnistäminen ei onnistu niin koita `sudo reboot` jolloin ainakin cgroup memory-muutokset astuvat voimaan ja ongelma korjaantuus
  - Testaa klusterin toimivuus `kubectl get nodes -o wide`
    - TODO: K3s server näyttäisi vievän 10% CPU ja 12% memoryä idlenä ollessaan. Katsotaan kannattaako tällä tiellä jatkaa?

- TODO: Siirretään tekniseen tilaan
  - Täällä ei käytetä wifiä vaan mennään lankaverkolla kiinni (Wifin saa siis disabloida)
  - Todellinen tarve tekniselle tilalle on vasta kun aletaan ottamaan sen laitteisiin kiinni. Alkuvaiheessa voidaan kuitenkin testata Ruuvitagien kantamaa ja saapa sen muutenkin pois jaloista
  - Voiko IP vaihtua? Kiinteä IP pitää asettaa uudestaan?
  - Pitää myös rakentaa sopiva teline mihin Raspi teknisessä tilassa pistetään (ettei tipu ja ettei tule liikaa pölyä päälle)
  - Tarvitsee hoitaa sisäverkon kaapelointi tekniseen tilaan
    - Reitittimeltä kaapeli takaisin talokaapeloinnin kautta tekniseen
    - Teknisessä Raspi suoraan kiinni (tai kytkimen kautta jatkossa)

- TODO: Hallintamekanismi
  - Miten kubernetesta ja muita applikaatioita hallinnoidaan? 

- TODO: Luodaan reitittimen asetuksissa Port Forward-tunneli julkiverkosta SSH:ta varten kiinteän IP:n porttiin esim. `*:1234` -> `192.168.1.120:22`
  - Nyt pitäisi saada yhteys raspiin myös ulokoverkosta
  - TODO: Mutta ei saada, joko operaattorin päässä blokataan tämä tai reitittimien kanssa on jumppaamista
  - TODO: Onko itseasiassa SSH:lle ulkoverkosta tarvetta? Isompi tarve on saada Grana näkyviin julkiverkosta

## Ohjelmistot
### InfluxDB
- Aikasarjatietokanta mittatulosten tallentamiseen
- https://blog.anoff.io/2020-12-run-influx-on-raspi-docker-compose/ 
- TODO: Varmuuskopiot
  - Mihin varmuuskopioidaan? Pilveen vai NAS:lle? Miten usein?
- TODO: Data retention policy
  - Real time data vs history data
  - https://docs.influxdata.com/influxdb/v2.1/process-data/common-tasks/downsample-data/

### Grafana
- Visualisointityöalu aikasarjadatalle
- Tarjotaan ulos portista :80
- TODO: Kirjautuminen? Read-only ilman kirjautumista?
- https://blog.anoff.io/2021-01-howto-grafana-on-raspi/

# Mittaukset

## RuuviTag (Huonelämpötilat, -kosteudet- ilmanpaineet)
- https://medium.com/@ville.alatalo/oma-s%C3%A4%C3%A4asema-ruuvitagilla-ja-grafanalla-25c823f20a20
- https://github.com/Scrin/RuuviCollector (Java 8)
  - Vaiko sittenkin Pythonpohjainen https://github.com/ttu/ruuvitag-sensor
- Jokaisen huonetermostaatin yhteyteen oma RuuviTag + muutama muu huone missä ei ole termostaattia (esim. kodinhoito)
- TODO: Mitä sitten jos RuuviTagit ei kuulukaan koko talosta?
  - External-antenni? / Erillinen bluetooth usb-dongle paremmall antennilla?
  - Rasberry PI Zero jonnekin tukiasemaksi? Olisiko tällä jotain muutakin käyttöä?
  - Ilmeisesti tukee myös Mesh-noodia, mietitään
- TODO: Tutkitaan mitä vaihtoehtoja RuuviTageilla on external sensoreille ja oman softan kirjoittamiselle

## Sähkönkulutus LED-indikaattorista
- Perusajatus täältä: https://hyotynen.iki.fi/kotiautomaatio/sahkonkulutuksen-seurantaa/
- Tilattiin [LM393-Valosensorimoduuli](https://www.elektroniikkaosat.com/c-67/p-163360505/Valosensorimoduuli-fotodiodi.html) joka antaa digitaalisen ulostulon
- Kytketään tämä suoraan Raspbin GPIO-pinneihin ja tehdään python-applikaatio joka interruptaa nousevalla reunalla --> saadaan pulssit nätisti kiinni
- Tarvitsee vielä logiikan joka laskee ja lähettää hetkellisen kulutuksen (esim. 5s päivitysvälillä ja tunti/minuutti/päiväkohtaisen kumulatiivisen arvon Influxiin)

## Lämmönvaihtimen data (vesien lämpötilat, ulkolämpötila)
- https://medium.com/@ville.alatalo/diy-omakotitalon-l%C3%A4mmityksen-mittaaminen-ja-visualisointi-cacfcd974a44
- https://olammi.iki.fi/sw/taloLogger/ (Python 2.4+)
- https://github.com/alatalo/ouman-collector (Python 2.7)
- TODO: Selvitä mitä takuulle tapahtuu jos laitteeseen kolvaa sarjaporttikytkennän 

## Swegon Casa R120 (???)

## Tuleva ilmalämpöpumppu (???)
- Mitsibishin pumpuissa on MELCloud jolla saadaan tietoa ulos pumpusta. Sitä voi tutkia esim tällä https://github.com/vilppuvuorinen/pymelcloud
- Keinoja löytyy myös tutkia asiaa suoraan pumpulta mutta vaatii temppuiluja https://chrdavis.github.io/hacking-a-mitsubishi-heat-pump-Part-1/
- Mm. Gree:lle on tehty myös temppuja suoraan kaukosäätimen asetuksia reverse-engineeraamalla https://www.dudley.nu/projects/heatpump-control/
