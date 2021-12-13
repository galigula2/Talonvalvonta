# Talonvalvontaprojekti

![Overall picture](/diagrams/Talonvalvonta.png)

Ajatukset toteutukselle saatiin Ville Alatalon hyvistä selonteoista
- https://medium.com/@ville.alatalo/oma-s%C3%A4%C3%A4asema-ruuvitagilla-ja-grafanalla-25c823f20a20
- https://medium.com/@ville.alatalo/diy-omakotitalon-l%C3%A4mmityksen-mittaaminen-ja-visualisointi-cacfcd974a44

# Rasperry PI

- Järjestelmän ytimenä toimii RasperryPI 4 Model B korttitietokone joka asennetaan tekniseen tilaan sopivasti toimilaitteiden ja verkkokaapin läheisyyteen. 
- Raspi kytketään IoT-wlaniin pois eikä anneta pääsyä kotiverkkoon
  - Hallintayhteys vaatii liittymisen IoT-wlaniin
  - Grafanan UI julkaistaan reitittimen läpi internettiin DynDNS tai vastaavan avulla --> myös kotiverkosta pääsee kätevästi katsomaan käyriä.

## Speksit
  - https://raspikauppa.fi/product/raspberry-pi-4-model-b-starter-kit/

## InfluxDB
- Aikasarjatietokanta mittatulostentallentamiseen
- https://docs.influxdata.com/influxdb/v1.4/introduction/installation/
- Varmuuskopiot
  - TODO: Mihin varmuuskopioidaan? Pilveen vai NAS:lle? Miten usein?


## Grafana
- https://github.com/fg2it/grafana-on-raspberry
- TODO: Nykytilanne-dashboard? Pohjakuvan päälle?
- TODO: Trendinäkymät?

# Mittaukset

## RuuviTag (Huonelämpötilat, -kosteudet- ilmanpaineet)
- https://github.com/Scrin/RuuviCollector (Java 8)
- Jokaisen huonetermostaatin yhteyteen oma RuuviTag + muutama muu huone missä ei ole termostaattia (esim. kodinhoito)
- TODO: Mitä sitten jos RuuviTagit ei kuulukaan koko talosta?

## Sähkönkulutus LED-indikaattorista
- TODO: Oma viritys valovastuksella vai joku valmis palikka?

## Lämmönvaihtimen data (vesien lämpötilat, ulkolämpötila)
- https://olammi.iki.fi/sw/taloLogger/ (Python 2.4+)
- https://github.com/alatalo/ouman-collector (Python 2.7)
- TODO: Selvitä mitä takuulle tapahtuu jos laitteeseen kolvaa sarjaporttikytkennän 

