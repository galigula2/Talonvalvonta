# Talonvalvontaprojekti

![Overall picture](/diagrams/Talonvalvonta.png)

Ajatukset toteutukselle saatiin Ville Alatalon hyvistä selonteoista
- https://medium.com/@ville.alatalo/oma-s%C3%A4%C3%A4asema-ruuvitagilla-ja-grafanalla-25c823f20a20
- https://medium.com/@ville.alatalo/diy-omakotitalon-l%C3%A4mmityksen-mittaaminen-ja-visualisointi-cacfcd974a44

# Rasberry PI 4 Model B

- Järjestelmän ytimenä toimii RasberryPI 4 Model B korttitietokone joka asennetaan tekniseen tilaan sopivasti toimilaitteiden ja verkkokaapin läheisyyteen. 
- Raspi kytketään IoT-wlaniin pois eikä anneta pääsyä kotiverkkoon
  - Hallintayhteys vaatii liittymisen IoT-wlaniin
  - Grafanan UI julkaistaan reitittimen läpi internettiin DynDNS tai vastaavan avulla --> myös kotiverkosta pääsee kätevästi katsomaan käyriä.
- [Technical Documentation](https://www.raspberrypi.com/documentation/)

## Speksit

Komponentti | Tiedot
-|-
Processor	| Broadcom BCM2711, quad-core Cortex-A72 (ARM v8)<br>64-bit SoC @ 1.5GHz
Memory | 	4GB LPDDR4 SDRAM
Connectivity | 2.4 GHz and 5.0 GHz IEEE 802.11b/g/n/ac wireless<br>LAN, Bluetooth 5.0, BLE<br>Gigabit Ethernet<br>2 × USB 3.0 ports<br> 2 × USB 2.0 ports.
GPIO | Standard 40-pin GPIO header<br>(fully backwards-compatible with previous boards)<br>[GPIO pins info and examples](https://projects.raspberrypi.org/en/projects/physical-computing/1)
Video & Sound	| 2 × micro HDMI ports (up to 4Kp60 supported)<br>2-lane MIPI DSI display port<br>2-lane MIPI CSI camera port<br>4-pole stereo audio and composite video port
Multimedia | H.265 (4Kp60 decode)<br>H.264 (1080p60 decode, 1080p30 encode)<br>OpenGL ES, 3.0 graphics
SD card support	| Micro SD card slot for loading operating system and data storage (64GB)
Input Power	| 5V DC via USB-C connector
Production lifetime | 	The Raspberry Pi 4 Model B will remain in production until at least January 2026.

## Perusasetukset
- Asennetaan [Rasberry Pi OS Lite 32 bit](https://www.raspberrypi.com/software/)
  - Ladattu suoraan Rasberry Pi Imagerilla.
  - Tämä myös alustaa 64Gb muistikortin FATR32:lla jolta Rasberry osaa bootata
- Lataamisen jälkeen [enabloidaan headless imageen wifi-yhdistäminen js SSH-tuki](https://medium.com/@nikosmouroutis/how-to-setup-your-raspberry-pi-and-connect-to-it-through-ssh-and-your-local-wifi-ac53d3839be9)
  - Windowsilla piti erikseen laittaa FAT32 boot-partitiolle drive letter jotta sinne pääsi käsiksi
  - WIFI voitaisiin laittaa yhdistämään tietoturvasyistä erilliseen IoT-verkkoon, mutta nykyisen reitittimen rajoitusten takia näin ei tehty (lisäksi jatkossa käytetään kuitenkin langalista verkkoa jolloin tämän merkitys pienenee)
- Käynnistetään Rasbi ja koitetaan ottaa yhteyttä
  - SSH-yhteys laitteeseen `ssh ip@192.168.1.120`, salasana `raspberry`
    - NOTE: As discussed [here](https://www.reddit.com/r/raspberry_pi/comments/hckfiv/can_you_explain_this_mystery_sshing_to_my_pi_4/) power management on the connecting side can cause SSH to hang after giving SSH password. On an ASUS Gaming laptop this meant that SSH was not working if the power cable was not plugged in (mostl likely this is only when in WIFI)
  - Vaihdetaan oletussalasana toiseksi
  - Ajetaan peruspäivitykset
  
- TODO: Siirretään tekniseen tilaan
  - Täällä oikeastaan ei käytetä wifiä ollenkaan vaan mennään lankaverkolla kiinni (Wifin saa siis disabloida)
  - Todellinen tarve tekniselle tilalle on vasta kun aletaan ottamaan sen laitteisiin kiinni. Alkuvaiheessa voidaan kuitenkin testata Ruuvitagien kantamaa ja saapa sen muutenkin pois jaloista
  - Voiko IP vaihtua? Kiinteä IP pitää asettaa uudestaan?
  - Pitää myös rakentaa sopiva teline mihin Raspi teknisessä tilassa pistetään (ettei tipu ja ettei tule liikaa pölyä päälle)
  - Tarvitsee hoitaa sisäverkon kaapelointi tekniseen tilaan
    - Reitittimeltä kaapeli takaisin talokaapeloinnin kautta tekniseen
    - Teknisessä Raspi suoraan kiinni (tai kytkimen kautta jatkossa)
- Asetetaan kiinteä IP reitittimen asetuksissa, esim `192.168.1.120`
  - Luodaan reitittimen asetuksissa Port Forward-tunneli julkiverkosta SSH:ta varten kiinteän IP:n porttiin esim. `*:1234` -> `192.168.1.120:22`
    - Nyt pitäisi saada yhteys raspiin myös ulokoverkosta
    - TODO: Mutta ei saada, joko operaattorin päässä blokataan tämä tai reitittimien kanssa on jumppaamista
    - TODO: Onko itseasiassa SSH:lle ulkoverkosta tarvetta? Isompi tarve on saada Grana näkyviin julkiverkosta

- TODO: Hallintamekanismi
  - Mitä käytetään normaaliin hallintaan? Tekisi mieli koittaa K3s:ää ja Fluxilla hakea GitReposta tiedot

## Ohjelmistot
### InfluxDB
- Aikasarjatietokanta mittatulostentallentamiseen
- https://docs.influxdata.com/influxdb/v1.4/introduction/installation/
- Varmuuskopiot
  - TODO: Mihin varmuuskopioidaan? Pilveen vai NAS:lle? Miten usein?


### Grafana
- https://github.com/fg2it/grafana-on-raspberry
- TODO: Nykytilanne-dashboard? Pohjakuvan päälle?
    - https://grafana.com/blog/2021/08/12/streaming-real-time-sensor-data-to-grafana-using-mqtt-and-grafana-live/ (?)
- TODO: Trendinäkymät?

### Java8(?)
- Tämä tarvitaan RuuviCollectorille, mutta onko oikeasti tarpeen? Ruuvien lukemiseen oli myös Python-kirjastoja
                                                     
### Python(?)

### Apuohjelmat

# Mittaukset

## RuuviTag (Huonelämpötilat, -kosteudet- ilmanpaineet)
- https://github.com/Scrin/RuuviCollector (Java 8)
  - Vaiko sittenkin Pythonpohjainen https://github.com/ttu/ruuvitag-sensor
- Jokaisen huonetermostaatin yhteyteen oma RuuviTag + muutama muu huone missä ei ole termostaattia (esim. kodinhoito)
- TODO: Mitä sitten jos RuuviTagit ei kuulukaan koko talosta?
  - External-antenni? / Erillinen bluetooth usb-dongle paremmall antennilla?
  - Rasberry PI Zero jonnekin tukiasemaksi? Olisiko tällä jotain muutakin käyttöä?
  - Ilmeisesti tukee myös Mesh-noodia, mietitään
- TODO: Tutkitaan mitä vaihtoehtoja RuuviTageilla on external sensoreille ja oman softan kirjoittamiselle

## Sähkönkulutus LED-indikaattorista
- TODO: Oma viritys valovastuksella vai joku valmis palikka?
- [Using a light-dependent resistor](https://projects.raspberrypi.org/en/projects/physical-computing/10)

## Lämmönvaihtimen data (vesien lämpötilat, ulkolämpötila)
- https://olammi.iki.fi/sw/taloLogger/ (Python 2.4+)
- https://github.com/alatalo/ouman-collector (Python 2.7)
- TODO: Selvitä mitä takuulle tapahtuu jos laitteeseen kolvaa sarjaporttikytkennän 

