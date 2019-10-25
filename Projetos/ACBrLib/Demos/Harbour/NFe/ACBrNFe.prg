#include "hbclass.ch"
#include "error.ch"

#define DC_CALL_CDECL          0x0010      // __cdecl
#define DC_CALL_STD            0x0020      // __stdcall

#ifdef _XHARBOUR_ 
#define ACBrLIB "ACBrNFe32.dll"
#define DLL_OSAPI DC_CALL_STD
#else
#if defined( __PLATFORM__WINDOWS )
#define ACBrLIB "ACBrNFe32.dll"
#define DLL_OSAPI DC_CALL_STD
#else
#define ACBrLIB "libacbrnfe64.so"
#define DLL_OSAPI DC_CALL_CDECL
#endif
#endif

#define STR_LEN 256

CREATE CLASS ACBrNFe
HIDDEN:
    VAR hHandle

    METHOD CheckResult(hResult)
    METHOD ProcessResult(buffer, bufferLen)

VISIBLE:
    METHOD New() CONSTRUCTOR
    METHOD New(eArqConfig, eChaveCrypt) CONSTRUCTOR
    DESTRUCTOR  Destroy

    METHOD Nome
    METHOD Versao

    METHOD ConfigLer(eArqConfig)
    METHOD ConfigGravar(eArqConfig)
    METHOD ConfigLerValor(eSessao, eChave)
    METHOD ConfigGravarValor(eSessao, eChave, eValor)

    METHOD CarregarXML(eArquivoOuXml)
    METHOD CarregarINI(eArquivoOuIni)
    METHOD ObterXml(AIndex)
    METHOD GravarXml(AIndex, eNomeArquivo, ePathArquivo)
    METHOD CarregarEventoXML(eArquivoOuXml)
    METHOD CarregarEventoINI(eArquivoOuIni)
    METHOD LimparLista()
    METHOD LimparListaEventos()

    METHOD Assinar()
    METHOD Validar()
    METHOD ValidarRegrasdeNegocios()
    METHOD VerificarAssinatura()

    METHOD StatusServico()
    METHOD Consultar(eChaveOuNFe)
    METHOD Inutilizar(ACNPJ, AJustificativa, Ano, Modelo, Serie, NumeroInicial, NumeroFinal)
    METHOD Enviar(ALote, Imprimir, Sincrono, Zipado)
    METHOD ConsultarRecibo(ARecibo)
    METHOD Cancelar(eChave, eJustificativa, eCNPJ, ALote)
    METHOD EnviarEvento(ALote)

    METHOD DistribuicaoDFePorUltNSU(acUFAutor, eCNPJCPF, eultNSU)
    METHOD DistribuicaoDFePorNSU(acUFAutor, eCNPJCPF, eNSU)
    METHOD DistribuicaoDFePorChave(acUFAutor, eCNPJCPF, echNFe)

    METHOD EnviarEmail(ePara, eChaveNFe, aEnviaPDF, eAssunto, eMensagem, eCc, eAnexos)
    METHOD EnviarEmailEvento(ePara, eChaveEvento, eChaveNFe, aEnviaPDF, eAssunto, eMensagem, eCc, eAnexos)

    METHOD Imprimir(cImpressora, nNumCopias, cProtocolo, bMostrarPreview, cMarcaDagua, bViaConsumidor, bSimplificado)
    METHOD ImprimirPDF()
    METHOD ImprimirEvento(eChaveNFe, eChaveEvento)
    METHOD ImprimirEventoPDF(eChaveNFe, eChaveEvento)
    METHOD ImprimirInutilizacao(eChaveNFe)
    METHOD ImprimirInutilizacaoPDF(eChaveNFe)

END CLASS

METHOD New(eArqConfig, eChaveCrypt) CLASS ACBrNFe
    local hResult, buffer, bufferLen, oErr

    ::hHandle := DllLoad(ACBrLIB)
    if ::hHandle = nil
        oErr := ErrorNew()
        oErr:Severity := ES_ERROR        
        oErr:Description := "Erro a carregar a dll [" + ACBrLIB + "]"
        Throw(oErr)
    endif
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_Inicializar", hb_StrToUTF8(eArqConfig), hb_StrToUTF8(eChaveCrypt))
    ::CheckResult(hResult) 
    RETURN Self

PROCEDURE Destroy CLASS ACBrNFe
    DllCall(::hHandle, DLL_OSAPI, "NFE_Finalizar")
    DllUnload(::hHandle)
    RETURN

METHOD CheckResult(hResult) CLASS ACBrNFe
    local buffer, bufferLen, oErr
    if hResult >= 0 
       RETURN nil
    endif    

    bufferLen := STR_LEN
    buffer := Space(bufferLen)

    DllCall(::hHandle, DLL_OSAPI, "NFE_UltimoRetorno", @buffer, @bufferLen)
    if bufferLen > STR_LEN
        buffer := Space(bufferLen)
        DllCall(::hHandle, DLL_OSAPI, "NFE_UltimoRetorno", @buffer, @bufferLen)        
    endif    

    oErr := ErrorNew()
    oErr:Severity := ES_ERROR
    oErr:Description := hb_UTF8ToStr(buffer)
    Throw(oErr)
    RETURN nil

METHOD ProcessResult(buffer, bufferLen) CLASS ACBrNFe
    if bufferLen > STR_LEN
        buffer := Space(bufferLen)
        DllCall(::hHandle, DLL_OSAPI, "NFE_UltimoRetorno", @buffer, @bufferLen)        
    endif
    RETURN buffer

METHOD Nome CLASS ACBrNFe
    local hResult, buffer, bufferLen
    bufferLen := STR_LEN
    buffer := Space(bufferLen)
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_Nome", @buffer, @bufferLen)
    ::CheckResult(hResult)
    RETURN ::ProcessResult(buffer, bufferLen)

METHOD Versao CLASS ACBrNFe
    local hResult, buffer, bufferLen
    bufferLen := STR_LEN
    buffer := Space(bufferLen)
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_Versao", @buffer, @bufferLen)
    ::CheckResult(hResult)
    RETURN ::ProcessResult(buffer, bufferLen)

METHOD ConfigLer(eArqConfig) CLASS ACBrNFe
    local hResult    
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_ConfigLer", hb_StrToUTF8(eArqConfig))
    ::CheckResult(hResult)
    RETURN nil

METHOD ConfigGravar(eArqConfig) CLASS ACBrNFe
        local hResult    
        hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_ConfigGravar", hb_StrToUTF8(eArqConfig))
        ::CheckResult(hResult)
        RETURN nil

METHOD ConfigLerValor(eSessao, eChave) CLASS ACBrNFe
    local hResult, buffer, bufferLen
    bufferLen := STR_LEN
    buffer := Space(bufferLen)   
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_ConfigLerValor", hb_StrToUTF8(eSessao), hb_StrToUTF8(eChave), @buffer, @bufferLen)
    ::CheckResult(hResult)
    RETURN ::ProcessResult(buffer, bufferLen)

METHOD ConfigGravarValor(eSessao, eChave, eValor) CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_ConfigGravarValor", hb_StrToUTF8(eSessao), hb_StrToUTF8(eChave), hb_StrToUTF8(eValor))
    ::CheckResult(hResult)
    RETURN nil

METHOD CarregarXML(eArquivoOuXml) CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_CarregarXML", hb_StrToUTF8(eArquivoOuXml))
    ::CheckResult(hResult)
    RETURN nil
    
METHOD CarregarINI(eArquivoOuIni) CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_CarregarINI", hb_StrToUTF8(eArquivoOuIni))
    ::CheckResult(hResult)
    RETURN nil

METHOD ObterXml(AIndex) CLASS ACBrNFe
    local hResult, buffer, bufferLen
    bufferLen := STR_LEN
    buffer := Space(bufferLen)   
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_ObterXml", AIndex, @buffer, @bufferLen)
    ::CheckResult(hResult)
    RETURN ::ProcessResult(buffer, bufferLen)

METHOD GravarXml(AIndex, eNomeArquivo, ePathArquivo) CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_GravarXml", AIndex, hb_StrToUTF8(eNomeArquivo), hb_StrToUTF8(ePathArquivo))
    ::CheckResult(hResult)
    RETURN nil

METHOD CarregarEventoXML(eArquivoOuXml) CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_CarregarEventoXML", hb_StrToUTF8(eArquivoOuXml))
    ::CheckResult(hResult)
    RETURN nil

METHOD CarregarEventoINI(eArquivoOuIni) CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_CarregarEventoINI", hb_StrToUTF8(eArquivoOuIni))
    ::CheckResult(hResult)
    RETURN nil

METHOD LimparLista() CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_LimparLista")
    ::CheckResult(hResult)
    RETURN nil

METHOD LimparListaEventos() CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_LimparListaEventos")
    ::CheckResult(hResult)
    RETURN nil

METHOD Assinar() CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_Assinar")
    ::CheckResult(hResult)
    RETURN nil

METHOD Validar() CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_Validar")
    ::CheckResult(hResult)
    RETURN nil

METHOD ValidarRegrasdeNegocios() CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_ValidarRegrasdeNegocios")
    ::CheckResult(hResult)
    RETURN nil

METHOD VerificarAssinatura() CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_VerificarAssinatura")
    ::CheckResult(hResult)
    RETURN nil

METHOD StatusServico() CLASS ACBrNFe
    local hResult, buffer, bufferLen
    bufferLen := STR_LEN
    buffer := Space(bufferLen)
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_StatusServico", @buffer, @bufferLen)
    ::CheckResult(hResult)
    RETURN ::ProcessResult(buffer, bufferLen)
    RETURN nil

METHOD Consultar(eChaveOuNFe) CLASS ACBrNFe
    local hResult, buffer, bufferLen
    bufferLen := STR_LEN
    buffer := Space(bufferLen)
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_Consultar", hb_StrToUTF8(eChaveOuNFe), @buffer, @bufferLen)
    ::CheckResult(hResult)
    RETURN ::ProcessResult(buffer, bufferLen)

METHOD Inutilizar(ACNPJ, AJustificativa, Ano, Modelo, Serie, NumeroInicial, NumeroFinal) CLASS ACBrNFe
    local hResult, buffer, bufferLen
    bufferLen := STR_LEN
    buffer := Space(bufferLen)
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_Inutilizar", hb_StrToUTF8(ACNPJ), hb_StrToUTF8(AJustificativa), Ano, Modelo, Serie, NumeroInicial, NumeroFinal, @buffer, @bufferLen)
    ::CheckResult(hResult)
    RETURN ::ProcessResult(buffer, bufferLen)

METHOD Enviar(ALote, Imprimir, Sincrono, Zipado) CLASS ACBrNFe
    local hResult, buffer, bufferLen
    bufferLen := STR_LEN
    buffer := Space(bufferLen)
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_Enviar", ALote, Imprimir, Sincrono, Zipado, @buffer, @bufferLen)
    ::CheckResult(hResult)
    RETURN ::ProcessResult(buffer, bufferLen)

METHOD ConsultarRecibo(ARecibo) CLASS ACBrNFe
    local hResult, buffer, bufferLen
    bufferLen := STR_LEN
    buffer := Space(bufferLen)
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_ConsultarRecibo", hb_StrToUTF8(ARecibo), @buffer, @bufferLen)
    ::CheckResult(hResult)
    RETURN ::ProcessResult(buffer, bufferLen)

METHOD Cancelar(eChave, eJustificativa, eCNPJ, ALote) CLASS ACBrNFe
    local hResult, buffer, bufferLen
    bufferLen := STR_LEN
    buffer := Space(bufferLen)
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_Cancelar", hb_StrToUTF8(eChave), hb_StrToUTF8(eJustificativa), hb_StrToUTF8(eCNPJ), ALote, @buffer, @bufferLen)
    ::CheckResult(hResult)
    RETURN ::ProcessResult(buffer, bufferLen)

METHOD EnviarEvento(ALote) CLASS ACBrNFe
    local hResult, buffer, bufferLen
    bufferLen := STR_LEN
    buffer := Space(bufferLen)
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_EnviarEvento", ALote, @buffer, @bufferLen)
    ::CheckResult(hResult)
    RETURN ::ProcessResult(buffer, bufferLen)

METHOD DistribuicaoDFePorUltNSU(acUFAutor, eCNPJCPF, eultNSU) CLASS ACBrNFe
    local hResult, buffer, bufferLen
    bufferLen := STR_LEN
    buffer := Space(bufferLen)
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_DistribuicaoDFePorUltNSU", hb_StrToUTF8(acUFAutor), hb_StrToUTF8(eCNPJCPF), hb_StrToUTF8(eultNSU), @buffer, @bufferLen)
    ::CheckResult(hResult)
    RETURN ::ProcessResult(buffer, bufferLen)

METHOD DistribuicaoDFePorNSU(acUFAutor, eCNPJCPF, eNSU) CLASS ACBrNFe
    local hResult, buffer, bufferLen
    bufferLen := STR_LEN
    buffer := Space(bufferLen)
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_DistribuicaoDFePorNSU", hb_StrToUTF8(acUFAutor), hb_StrToUTF8(eCNPJCPF), hb_StrToUTF8(eNSU), @buffer, @bufferLen)
    ::CheckResult(hResult)
    RETURN ::ProcessResult(buffer, bufferLen)

METHOD DistribuicaoDFePorChave(acUFAutor, eCNPJCPF, echNFe) CLASS ACBrNFe
    local hResult, buffer, bufferLen
    bufferLen := STR_LEN
    buffer := Space(bufferLen)
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_DistribuicaoDFePorChave", hb_StrToUTF8(acUFAutor), hb_StrToUTF8(eCNPJCPF), hb_StrToUTF8(echNFe), @buffer, @bufferLen)
    ::CheckResult(hResult)
    RETURN ::ProcessResult(buffer, bufferLen)

METHOD EnviarEmail(ePara, eChaveNFe, aEnviaPDF, eAssunto, eMensagem, eCc, eAnexos) CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_EnviarEmail", hb_StrToUTF8(ePara), hb_StrToUTF8(eChaveNFe), aEnviaPDF, hb_StrToUTF8(eAssunto), hb_StrToUTF8(eMensagem), hb_StrToUTF8(eCc), hb_StrToUTF8(eAnexos))
    ::CheckResult(hResult)
    RETURN nil

METHOD EnviarEmailEvento(ePara, eChaveEvento, eChaveNFe, aEnviaPDF, eAssunto, eMensagem, eCc, eAnexos) CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_EnviarEmailEvento", hb_StrToUTF8(ePara), hb_StrToUTF8(eChaveEvento), hb_StrToUTF8(eChaveNFe), aEnviaPDF, hb_StrToUTF8(eAssunto), hb_StrToUTF8(eMensagem), hb_StrToUTF8(eCc), hb_StrToUTF8(eAnexos))
    ::CheckResult(hResult)
    RETURN nil

METHOD Imprimir(cImpressora, nNumCopias, cProtocolo, bMostrarPreview, cMarcaDagua, bViaConsumidor, bSimplificado) CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_Imprimir", hb_StrToUTF8(cImpressora), nNumCopias, hb_StrToUTF8(bMostrarPreview), hb_StrToUTF8(cMarcaDagua), hb_StrToUTF8(bViaConsumidor), hb_StrToUTF8(bSimplificado))
    ::CheckResult(hResult)
    RETURN nil

METHOD ImprimirPDF() CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_ImprimirPDF")
    ::CheckResult(hResult)
    RETURN nil

METHOD ImprimirEvento(eChaveNFe, eChaveEvento) CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_ImprimirEvento", hb_StrToUTF8(eChaveNFe), hb_StrToUTF8(eChaveEvento))
    ::CheckResult(hResult)
    RETURN nil

METHOD ImprimirEventoPDF(eChaveNFe, eChaveEvento) CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_ImprimirEventoPDF", hb_StrToUTF8(eChaveNFe), hb_StrToUTF8(eChaveEvento))
    ::CheckResult(hResult)
    RETURN nil

METHOD ImprimirInutilizacao(eChaveNFe) CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_ImprimirInutilizacao", hb_StrToUTF8(eChaveNFe))
    ::CheckResult(hResult)
    RETURN nil

METHOD ImprimirInutilizacaoPDF(eChaveNFe) CLASS ACBrNFe
    local hResult
    hResult := DllCall(::hHandle, DLL_OSAPI, "NFE_ImprimirInutilizacaoPDF", hb_StrToUTF8(eChaveNFe))
    ::CheckResult(hResult)
    RETURN nil