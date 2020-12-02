#include 'protheus.ch'

/* ========================================================================== 
C�digo-fonte de teste do Grid Client - Utiliza��o com Prepare() e Execute()
=========================================================================== */
User Function GridBeta()
Local aStart := {1,2}
Local oGrid
Local nTimer := seconds()
Local lGridOk := .f. , nI

// Cria o objeto Client de interface com o Grid
oGrid := GridClient():New()

// Define o nome das fun��es de prepara��o de ambiente e execu��o
cFnStart := 'U_TGRIDS'
cFnExec  := 'U_TGRIDA'

lGridOk := oGrid:Prepare(cFnStart,aStart,cfnExec)

If !lGridOk   
    // Caso o Grid n�o tenha sido preparado com sucesso, recupere   
    // os detalhes e mensagem de erro atrav�s do m�todo GetError()   
    MsgStop(oGrid:GetError(),"Falha de Prepara��o do Grid")   
    // Finaliza o processo   
    oGrid:Terminate()   
    // Este objeto n�o pode ser mais usado . Limpa   
    oGrid := NIL   
    Return
Endif

    // Parte pra execu��o � Envio de 200 requisi��es
    For nI := 1 to 200   
        // Looping de envio de dados   
        // O par�metro de execu��o enviado � un n�mero   
        lGridOk := oGrid:Execute(nI)   
        If !lGridOk           
            EXIT   
        Endif
    Next

    If lGridOk   
        // At� aqui, sem erros? Ok, finaliza o Grid.   
        lGridOk := oGrid:Terminate()   
    Endif

    IF !lGridOk   
        
        // Houve algum erro, ou no processamento, ou na   
        // finaliza��o do Grid. Verifica os arrays de propriedades   
        If !empty(oGrid:aErrorProc)          
            // Houve um ou mais erros fatais que abortaram o processo          
            // [1] : N�mero sequencial da instru��o enviada que n�o foi processada          
            // [2] : Par�metro enviado para processamento          
            // [3] : Identifica��o do Agente onde ocorreu o erro          
            // [4] : Detalhes da ocorr�ncia de erro          
            varinfo('ERR',oGrid:aErrorProc)   
        Endif   

        If !empty(oGrid:aSendProc)          
            // retorna lista de chamadas que foram enviadas e n�o foram executadas          
            // [1] N�mero sequencial da instru��o          
            // [2] Par�metro de envio          
            // [3] Identifica��o do Agente que recebeu a requisi��o          
            varinfo('PND',oGrid:aSendProc)   
        Endif   
            
        MsgStop(oGrid:GetError(),"Falha de Processamento em Grid")
    Else   
        // Tudo certo   
        MsgInfo("Processamento completo com sucesso em "+str(seconds()-nTimer,12,3))
    Endif

Return

STATIC _ReqNum := 0
// =====================================================================
// Prepara��o de ambiente
// Executada por cada agente, para preparar o ambiente para rodar
// a fun��o de processamento do Grid
// Num Grid para executar fun��es que dependem de infraestrutura do ERP,
// neste ponto deve ser colocado um PREPARE ENVIRONMENT
// =====================================================================

USER Function TGRIDS()
    Conout("[DEMO] Preparando Ambiente")
    // Espera rand�mica, para consumir algum tempo  (de 1 a 10 segundos )
    sleep( Randomize(1000,10000) )
    Conout("[DEMO] Ambiente Preparado")
Return .T.
// =====================================================================
// Execu��o de Requisi��es de Processamento
// Recebe como par�metro o conte�do informado ao m�todo Execute()
// Caso n�o haja nenhuma necessidade de conte�do retornado
// diretamente pela chamada, a fun��o deve retornar NIL.
// Caso seja retornado qualquer outro valor, ele ser�
// armazenado pelo GridClient e poder� ser recuperado posteriormente
// =====================================================================

USER Function TGRIDA(xParam)
    Conout("[DEMO] REQUISICAO ["+str(++_ReqNum,4)+"] Processando Parametro ["+str(xParam,4)+"]")
    // Espera rand�mica, para consumir algum tempo ( entre 0,5 e 5 segundos )
    sleep( Randomize(500,5000) )
    Conout("[DEMO] REQUISICAO ["+str(++_ReqNum,4)+"] OK")
Return 
