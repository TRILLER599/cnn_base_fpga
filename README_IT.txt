
    L'obiettivo principale di questo progetto è verificare la possibilità di 
implementare un sistema di addestramento per grandi reti neurali (NN) su un 
insieme di dispositivi FPGA per ridurre significativamente il tempo di 
addestramento rispetto alle schede grafiche.
    
    La parte centrale del progetto consiste in una semplice rete neurale 
convoluzionale su FPGA con calcoli completamente paralleli/con pipeline. 
Nel progetto presentato, viene utilizzato un singolo cristallo, ma si suppone 
che ogni strato/vari strati della NN siano calcolati su un chip separato, e 
la connessione tra gli strati è organizzata tramite trasmettitori/ricevitori ad 
alta velocità (transceiver) con un'interfaccia semplice basata su FIFO.
I calcoli sono compressi per il riutilizzo delle risorse, ma in alcune parti 
non sono ancora ottimali. Tuttavia, c'è ampio spazio per la ricerca.
Dopo l'implementazione del meccanismo di "attenzione", sarà il momento di 
ottimizzazioni significative.
    Per l'addestramento è stato scritto un protocollo di gestione dei pacchetti 
UDP lato FPGA e la sua controparte client per PC in Python.
    La stessa rete neurale è stata implementata in NumPy per l'esecuzione dei 
calcoli sulla CPU e per il controllo della correttezza dell'algoritmo FPGA.

    Non sono un programmatore professionista, ma uno sviluppatore FPGA, quindi 
per favore non giudicatemi duramente :)


    1. La cartella "classInt16CNN"
    Contiene una rete neurale convoluzionale eseguita su CPU utilizzando 
puramente NumPy. Eseguendo classInt16CNN_Transfer_00_Base.py nell'interprete, 
avvierai l'addestramento di una rete convoluzionale a tre strati per 2 epoche, 
come definito dal parametro EPOCHA. Prima di farlo, assicurati di decompimere 
mnist_original_archive.zip nella stessa cartella. I livelli convoluzionali e 
completamente connessi sono descritti in conv_layer.py e fully_layer.py. 
L'addestramento di una singola epoca richiede circa 15 minuti. I dati stampati 
nella console possono essere utilizzati per confrontare l'addestramento con una 
rete neurale simile su FPGA. Attenzione! È necessario mantenere la struttura 
delle cartelle del repository, poiché i "pesi" e le configurazioni della classe 
classInt16CNN vengono utilizzati durante l'addestramento della rete neurale 
su FPGA. Le dimensioni ridotte della rete sono dovute al lungo tempo di 
esecuzione del modello di riferimento e non alle risorse FPGA disponibili.


    2. La cartella "cnn_sv" contiene i sorgenti del progetto FPGA. 
    Il codice non contiene primitivi, ma era orientato verso il DSP di Xilinx. 
Comunque, non ci dovrebbero essere complicazioni e problemi neanche per Altera e 
simili.
    
neural_network_top.sv (         - Il file di livello superiore
    input clk,                  - la frequenza della rete neurale deve essere<clk_eth
    input clk_eth,              - Frequenza Ethernet 10G = 312,5 MHz
    input i_eth_conf_complete,  - Segnale Ethernet pronto
    
    Le restanti porte sono ottiche standard RX e TX da 10 Gigabit
);
    
reti_neurali_base_0929.sv (     - Il file di livello superiore della rete neurale
    Viene generato dai sorgenti pseudo-C++ tramite una versione personalizzata 
    di HLS, quindi la leggibilità e la comprensibilità del codice non sono 
    molto elevate.
);
    
    3. Configurazione della connessione
    Nelle impostazioni della scheda di rete ottica da dieci gigabit, devono 
essere attivati i jumbo frame! Il protocollo di gestione dell'addestramento 
utilizza pacchetti UDP con payload massimo di 8192 byte. L'indirizzo IP della 
FPGA è impostato su 192.168.19.128, quindi la scheda di rete deve trovarsi 
nella sottorete 19. Sono implementate solo risposte agli ARP request e comandi 
di addestramento: al momento nient'altro è stato fatto.
Prima dell'inizio dell'addestramento, la scheda deve essere programmata e 
l'indirizzo IP deve corrispondere a MAC=33:11:22:00:AA:BB. Spero di trovare 
il tempo per implementare anche la risposta al ping.


    4. scenario.py - Implementa lo scenario di addestramento delle reti neurali sulla FPGA.
    Per avviare il processo di addestramento delle reti neurali sulla FPGA, è 
necessario eseguire proprio questo script. Utilizza la classe 
classGestioneFunzionale e i suoi metodi dal file pyGestioneFunzionale.py, 
dove è implementato il protocollo di comunicazione con la FPGA.
La classe classGestioneFunzionale estrae i "pesi" e altri parametri modificabili 
dalla classInt16CNN, garantendo così il controllo sulla correttezza del 
funzionamento della FPGA. È stato creato un client echo molto semplice, 
quindi non si raggiunge la massima velocità di addestramento. Da qui, segue 
che far funzionare la FPGA alla massima frequenza non ha molto senso - comunque 
rimarrebbe inattiva. Tutto il potenziale della FPGA e tutto il flusso di rete
 sono necessari per compiti molto più seri :)
