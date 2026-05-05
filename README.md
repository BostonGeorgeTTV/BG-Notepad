# BG-Notepad
Notepad fivem

https://www.youtube.com/watch?v=SE7lrddCBvQ

<img width="1672" height="941" alt="ChatGPT Image 6 mag 2026, 01_01_55" src="https://github.com/user-attachments/assets/a1b3e975-b367-485a-86b0-a5689e09bdd1" />

BG Notepad è uno script semplice, leggero e curato per aggiungere un sistema di blocco note realistico al tuo server FiveM. I player possono scrivere biglietti, salvarli come item con metadata unici e condividerli con altri giocatori, rendendo ogni nota persistente e personale.

Perfetto per server roleplay, investigazioni, attività criminali, business, meccanici, polizia, medici o qualsiasi situazione in cui serva lasciare messaggi, ordini, appunti o indizi.

Lo script include un’interfaccia pulita e intuitiva, supporto ai metadata dell’item e un sistema di firma personalizzabile. Quando il player stampa o salva il biglietto, può scegliere se firmarlo con il proprio nome oppure in modo anonimo, mostrando “Anonimo” al posto del nome.

Compatibile con ESX, QBCore e qbox, con supporto per inventari basati su metadata come ox_inventory e integrazione adattabile anche ad altri inventari.

Caratteristiche principali:

• Sistema notepad realistico
• Item con metadata unici
• Firma con nome player o modalità anonima
• Interfaccia semplice e moderna
• Perfetto per roleplay investigativo e criminale
• Compatibile ESX, QBCore e qbox
• Configurazione facile
• Resource leggera e ottimizzata

Con BG Notepad, ogni appunto può diventare un indizio, un contratto, una prova o semplicemente un messaggio lasciato nel mondo RP.

Resource notepad compatibile con ESX, QBCore e qbox.

## Funzioni

- Creazione di un biglietto con testo salvato nei metadata dell'item.
- Dialog di stampa con scelta tra nome del player e `Anonimo`.
- Auto-detect framework: ESX, QBCore, qbox o standalone.
- Supporto inventory: `ox_inventory`, `qb-inventory`/compatibili e fallback framework.

## Configurazione

Modifica `shared/config.lua` se non vuoi usare il rilevamento automatico.

```lua
Config.Item = 'notepad'

-- 'auto', 'esx', 'qbcore', 'qbox', 'standalone'
Config.Framework = 'auto'

-- 'auto', 'ox_inventory', 'qb_inventory', 'framework'
Config.Inventory = 'auto'

Config.RegisterUsableItem = true
Config.Debug = false
```

Con `auto`, lo script prova a rilevare prima `qbx_core`, poi `qb-core`, poi `es_extended`. Per l'inventario preferisce `ox_inventory`, poi gli inventari QB compatibili, poi il metodo del framework.

## Installazione comune

1. Rinomina la cartella in `bg_notepad`.
2. Inserisci la resource nella cartella resources del server.
3. Aggiungi in `server.cfg`:

```cfg
ensure bg_notepad
```

Assicurati che `bg_notepad` parta dopo il framework e dopo l'inventario.

## Installazione con ox_inventory

Aggiungi l'item in `ox_inventory/data/items.lua`:

```lua
['notepad'] = {
    label = 'Notepad',
    weight = 100,
    stack = false,
    close = true,
    consume = 0,
},
```

Poi aggiungi l'use client in `ox_inventory/modules/items/client.lua`:

```lua
Item('notepad', function(data, slot)
	ox_inventory:useItem(data, function(data)
		if data then
			exports.bg_notepad:openNotepad(slot.metadata)
		end
	end)
end)
```

Questo è il metodo consigliato per ESX + ox_inventory e qbox + ox_inventory, perché mantiene correttamente i metadata del biglietto.

## Installazione QBCore / qb-inventory

Aggiungi l'item in `qb-core/shared/items.lua`:

```lua
notepad = {
    name = 'notepad',
    label = 'Notepad',
    weight = 100,
    type = 'item',
    image = 'notepad.png',
    unique = true,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Biglietto scritto'
},
```

Copia `ox_items/notepad.png` nella cartella immagini del tuo inventario, ad esempio `qb-inventory/html/images/notepad.png`.

Non devi aggiungere un evento manuale: se `Config.RegisterUsableItem = true`, `bg_notepad` registra automaticamente l'item usabile con QBCore.

Config consigliata:

```lua
Config.Framework = 'qbcore'
Config.Inventory = 'qb_inventory'
```

Puoi lasciare entrambi su `auto` se le resource hanno i nomi standard `qb-core` e `qb-inventory`.

## Installazione qbox

qbox usa normalmente `qbx_core` e spesso `ox_inventory`. In quel caso usa la configurazione ox_inventory sopra.

Config consigliata:

```lua
Config.Framework = 'qbox'
Config.Inventory = 'ox_inventory'
```

Se usi un inventario QB compatibile, puoi usare:

```lua
Config.Framework = 'qbox'
Config.Inventory = 'qb_inventory'
```

Con `Config.RegisterUsableItem = true`, lo script prova anche a registrare l'item tramite `exports.qbx_core:CreateUseableItem`.

## Export client

Puoi aprire il notepad anche da altre resource:

```lua
exports.bg_notepad:openNotepad(metadata)
```

Per creare un biglietto nuovo:

```lua
exports.bg_notepad:openNotepad({})
```

## Metadata usati

```lua
{
    mode = 'view',
    title = 'MemoryRp',
    object = 'Testo del biglietto',
    save = 'Nome Player' -- oppure 'Anonimo'
}
```

`save` è il valore mostrato come firma/nome del biglietto.
