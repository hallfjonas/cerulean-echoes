
## Tech Stack
- 2 x Launchontrol?
- 1 x Launchkeys mit pads

- LLM komponente?
-

- Techincal Feasibilitiy
    - Müssen darauf auchten dass CPU-Auslastung nicht zu hoch wird

## Decisions
- Ein gemeinsamer track wird von allen MIDI geraeten gesteuert
    - LC 1: Fundament
    - LC 2: Farbe
    - LC 2 - Spalte 8: GLobal Controls fuer alle MIDI Geraete
    - LK: Pads fuer (einmalige) Samples
    - LK: Knobs fuer Filter auf Keys
    - LK: Keys


## Offene Fragen
- Wo ist der Globale Regler?
- Brauchen wir global knobs?

- Soll am Mac etwas verändert werden können wahrend der Session?
    - Was waere das Ziel?
        - Mehr Flexibilitaet im Musikbauen
        - Personalisierung
        - Leute koennen einfach kreative neue sounds bauen
    - Risiko
        - Tracks koennten schnell kaputt gehen
        - Vielleicht dreht sich dann viel darum


- Wie sollen die beiden Launchcontrols zusammen funktionieren?
    - Entscheidung:
        - Ein gemeinsamer Track;
            - LC 1:
                -
            - LC 2:
                -
    - Optionen
        -
            - Man könnte einen sehr komplexen Track bauen mit sehr vielen verschiedenen Komponenten

        - Zwei verschiedene Tracks
            - Wenn verschieden, müssen die basics sehr kompatibel oder sogar identisch sein
            - Die einzenlnen Spalten sollten die gleichen (oder sehr ähnliche) Instrumente beschreiben
            - Rechte spalte ist global für den jeweiligen controller
            - Knobs sollten auch identische funktionlität haben

## Tracks
- Ambients
    - Global knobs:
- Groove Techno
- House

## Checklist
+ In allen tracks muessen die ersten Varianten sehr gut zusammen passen
+ In allen tracks muessen die standard Knobeinstellungen muessen gut klingen
+ Wie kann man Default-Werte für Knobs bestimmen die nicht = min sind? Und wie kann man die Knob-Farbe so anpassen dass man die Default-Werte gut erkennen kann?


## TOP 10
+ Midi Device setups fixen: Können alle drei Midicontroller effizient gleichzeitig laufen?
+ 16 Samples auf Pads belegen (pro Track)
+ Sound design für Keys (pro Track)
+ Fallback-solution für duo setup (Launchcontrol + Launchkeys) oder nur (2x Launchcontrol)
+ House Track in neuem Mapping erstellen, zum Laufen bringen und auf 90% bringen
+ Lautsprecher kaufen
+ Lösung für wechsel der Tracks finden (möglichst seamless)
+ Anleitung für die Teilnehmer vorbereiten
+ Ambient Track perfektionieren

## Done
+ Groove Techno in neuem Mapping zum Laufen bringen und auf 90% bringen
+ Entscheiden wie viele Varianten wir zusammen ausprobieren wollen
+ Ambient Track zum Laufen und auf 90% bringen
+ Abstraktion für die LCs überlegen, sodass verständnis von einem Track zu dem nächsten übergeht