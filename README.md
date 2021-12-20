# Talonvalvontaprojekti

![Overall picture](/diagrams/Talonvalvonta.png)

Ajatukset toteutukselle saatiin Ville Alatalon hyvistä selonteoista
- https://medium.com/@ville.alatalo/oma-s%C3%A4%C3%A4asema-ruuvitagilla-ja-grafanalla-25c823f20a20
- https://medium.com/@ville.alatalo/diy-omakotitalon-l%C3%A4mmityksen-mittaaminen-ja-visualisointi-cacfcd974a44

# Rasperry PI 4 Model B

- Järjestelmän ytimenä toimii RasperryPI 4 Model B korttitietokone joka asennetaan tekniseen tilaan sopivasti toimilaitteiden ja verkkokaapin läheisyyteen. 
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

## Käyttöjärjestelmä
- [Rasperry Pi OS](https://www.raspberrypi.com/software/)

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
  - Rasperry PI Zero jonnekin tukiasemaksi? Olisiko tällä jotain muutakin käyttöä?
  - Ilmeisesti tukee myös Mesh-noodia, mietitään
- TODO: Tutkitaan mitä vaihtoehtoja RuuviTageilla on external sensoreille ja oman softan kirjoittamiselle

## Sähkönkulutus LED-indikaattorista
- TODO: Oma viritys valovastuksella vai joku valmis palikka?
- [Using a light-dependent resistor](https://projects.raspberrypi.org/en/projects/physical-computing/10)

## Lämmönvaihtimen data (vesien lämpötilat, ulkolämpötila)
- https://olammi.iki.fi/sw/taloLogger/ (Python 2.4+)
- https://github.com/alatalo/ouman-collector (Python 2.7)
- TODO: Selvitä mitä takuulle tapahtuu jos laitteeseen kolvaa sarjaporttikytkennän 

