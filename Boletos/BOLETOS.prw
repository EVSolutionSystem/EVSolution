#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "MSOLE.CH"
#include "TBICONN.CH"
#include "TOPCONN.CH"
#define cENTER CHR(13)+CHR(10)

/*���������������������������������������������������������������������������
��� Programa      � BOLETOS                          � Data � 19/08/2014  ���
�������������������������������������������������������������������������͹��
��� Descricao     � Programa para Geracao de Boleto Grafico Itau          ���
���				  �	utilizando o Objeto FWMSPTRINTER.					  ���
�������������������������������������������������������������������������͹��
��� Desenvolvedor � Eduardo Augusto      � Empresa � EV Solu��es Intelig  ���
��� Alterado por  � Valdemir Jose        � Empresa � EV Solu��es Intelig  ���
�������������������������������������������������������������������������͹��
��� Linguagem     � Advpl      � Versao � 11    � Sistema � Microsiga     ���
�������������������������������������������������������������������������͹��
��� Modulo(s)     � SIGAFIN                                               ���
�������������������������������������������������������������������������͹��
��� Tabela(s)     � SM0 / SE1 / SEE / SA6                                 ���
�������������������������������������������������������������������������͹��
��� Observacao    �  Alterado Dia 23/09/2014                              ���
���������������������������������������������������������������������������*/

User Function BOLETOS(aVetor, lChkBol, lChkBor)
Private oPrint   := Nil
Private nClrAzul := RGB(063,072,204)
Private nClrVerd := RGB(032,166,072)
Private nClrVerm := RGB(237,028,036)
Private oFont18N,oFont18,oFont16N,oFont16,oFont14N,oFont12N,oFont10N,oFont14,oFont12,oFont10,oFont08N
Private _limpr	 		:= .T.
Private oFontTit		:= oFont08N
Private lAdjustToLegacy := .F.
Private lDisableSetup   := .T.
Private _aBoletos  := {}
Private lEnd	   := .F.

oFont18N	:= TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)
oFont18 	:= TFont():New("Arial",18,18,,.F.,,,,.T.,.F.)
oFont16N	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
oFont16 	:= TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
oFont14N	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
oFont14 	:= TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
oFont12		:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
oFont12N	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
oFont08		:= TFont():New("Arial",07,07,,.T.,,,,.T.,.F.)
oFont08N	:= TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
oFont06N	:= TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
oFont06		:= TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
oFont05		:= TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)

DbSelectArea("SEE")
SEE->(DbSetOrder(1))	// EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
IF SEE->(DbSeek(xFilial("SEE") + _cBanco + _cAgencia + _cConta + _cSubcta ))
	//Processamento da gera��o de boletos
	oObj := MsNewProcess():New({|lEnd| if((SEE->EE_XIMPBOL = "S"),ImpBol(aVetor), NImpBol(aVetor)), AddBordero(aVetor) },"Processando","Gerando Boletos...",.T.)
	oObj:Activate()
Endif

Return



Static Function NImpBol(aVetor)
Local nCont     := 0
Local nRegis    := 0

	aEval(aVetor, { |x| if(x[1]=.T.,nRegis++,0) })

	For i := 1 to Len(aVetor)

	  If aVetor[i,1] == .T.

   		DbSelectArea("SE1")
		SE1->(DbSetOrder(1))
		SE1->(DbSeek(xFilial("SE1") + aVetor[i,2] + aVetor[i,3] + aVetor[i,4] + aVetor[i,12]))

		DbSelectArea("SEE")
		SEE->(DbSetOrder(1))	// EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
		SEE->(DbSeek(xFilial("SEE") + _cBanco + _cAgencia + _cConta + _cSubcta ))
		_cDvAge		:= SEE->EE_DVAGE
		_cDvCta		:= SEE->EE_DVCTA
		_cCart		:= SEE->EE_CODCART
		_nJuros		:= SUPERGETMV('MV_XJUROS',.F.,0)       //SEE->EE_JUROS
		_nMulta		:= SUPERGETMV('MV_XMULTA',.F.,0)		//SEE->EE_MULTA
		_cProtesto	:= SEE->EE_DIASPRT
		_cCodEmp	:= SEE->EE_CODEMP
		aAdd(_aBoletos,{SE1->(Recno()), SE1->E1_NUM, SE1->E1_TIPO, SC5->(Recno()), SC5->C5_NUM, ""})
		//u_NNCBLDDV(_aBoletos)
      endif
    Next

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BOLETOS   �Autor  �EV Solucoes         � Data �  06/08/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Impressao de Boeltos                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Manutencao� Eduardo / Valdemir                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpBol(aVetor)
Local nCont     := 0
Local nRegis    := 0
Local aVerif    := aClone(aVetor)
Local cPath     := GetSrvProfString("StartPath","")
Local aEmail    := {}
Local aError    := {}

aEval(aVetor, { |x| if(x[1]=.T.,nRegis++,0) })

if oObj !=nil
	oObj:SetRegua1( Len(aVetor) )
	oObj:SetRegua2( nRegis )
Endif

For i := 1 to Len(aVetor)
    oObj:IncRegua1("Processando, Analisando os titulos " )
	If aVetor[i,1] == .T.
	    oObj:IncRegua2("Gerando o boleto... Titulo: "+aVetor[i,3] )
		nCont++
   		DbSelectArea("SE1")
		SE1->(DbSetOrder(1))
		SE1->(DbSeek(xFilial("SE1") + aVetor[i,2] + aVetor[i,3] + aVetor[i,4] + aVetor[i,12]))

		DbSelectArea("SEE")
		SEE->(DbSetOrder(1))	// EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
		SEE->(DbSeek(xFilial("SEE") + _cBanco + _cAgencia + _cConta + _cSubcta ))
		_cDvAge		:= SEE->EE_DVAGE
		_cDvCta		:= SEE->EE_DVCTA
		_cCart		:= SEE->EE_CODCART
		_nJuros		:= SUPERGETMV('MV_XJUROS',.F.,0)       //SEE->EE_JUROS
		_nMulta		:= SUPERGETMV('MV_XMULTA',.F.,0)		//SEE->EE_MULTA
		_cProtesto	:= SEE->EE_DIASPRT
		_cCodEmp	:= SEE->EE_CODEMP
		aAdd(_aBoletos,{SE1->(Recno()), SE1->E1_NUM, SE1->E1_TIPO, SC5->(Recno()), SC5->C5_NUM, ""})
		u_NNCBLDDV(_aBoletos)
		cArquivo  := "bol_" + AllTrim(SE1->E1_NUM) + AllTrim(SE1->E1_PARCELA)
		cFileName := "C:\EVAUTO\AReceber\Boletos\" + cArquivo + ".pdf"
		// Se encontrar o boleto, renomeia para outro nome
		cTime := StrTran(Time(),':','')
		if file(cFileName)
		   FRename(cFileName, cFileName+'-'+dtos(dDatabase)+cTime+'.old')
		endif
		// Impressao
		oPrint := FWMSPrinter():New(cArquivo, IMP_PDF, lAdjustToLegacy,, lDisableSetup,,,,,,,.F.,)// Ordem obrig�toria de configura��o do relat�rio
		oPrint:SetResolution(72)			// Default
		oPrint:SetPortrait() 				// SetLandscape() ou SetPortrait()
		oPrint:SetPaperSize(9)				// A4 210mm x 297mm  620 x 876
		oPrint:SetMargin(10,10,10,10)		// < nLeft>, < nTop>, < nRight>, < nBottom>
		oPrint:cPathPDF := "C:\EVAUTO\AReceber\Boletos\"
		//oPrint:SetViewPdf(_limpr)
		oPrint:StartPage()   	// Inicia uma nova p�gina
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA ),.F.))

		//	Montagem do Box + Dados
		// < nRow>, < nCol>, < nBottom>, < nRight>, [ cPixel]
		// 1� Parte
		_cBcoLogo :=""
		_cDigBanco:=""
		aBcos     := { {"341","7","Logoitau.jpg"},{"237","2","LogoBradesco.jpg"},{"399","9", "Logohsbc.jpg" },{"033","7", "Logo033.jpg" } }
		nF 		  := ASCan(aBcos ,{|x|, x[1] == _cBanco })

		If nF == 0
			MsgBox(Iif(Empty(_cBanco),"O numero do banco nao foi informado","Nao ha layout previsto para o banco " + _cBanco))
		Else
			_lContinua := .T.
			_cDigBanco := aBcos[nF,2]
			_cBcoLogo  := "Logo"+Alltrim(_cBanco)+".JPG"
		EndIf

		oPrint:SayBitmap(0020,0025,_cBcoLogo,0085,0020)

		If _cBanco = "399"
			oPrint:Say(0036,0110, "|" + "399" + "-" + "9" + "|" ,oFont18N,100)	// C�digo do Banco + D�gito
		ElseIf _cBanco = "341"
			oPrint:Say(0036,0110, "|" + _cBanco + "-" + _cDigBanco + "|" ,oFont18N,100)	// C�digo do Banco + D�gito
		Else
			oPrint:Say(0036,0110, "|" + _cBanco + "-" + _cDigBanco + "|" ,oFont18N,100)	// C�digo do Banco + D�gito
		EndIf

		cCgcSM0 := SM0->M0_CGC
		oPrint:Say (0036, 0448,"Comprovante de Entrega",oFont12N )	// Comprovante de Entrega
		BuzzBox  (0040,0025,0065,0250)	// Box Benefici�rio + Cnpj
		oPrint:Say (0046, 0026,"Benefici�rio",oFont06N )
		oPrint:Say (0056, 0026,Alltrim(Substr(SM0->M0_NOMECOM,1,30)),oFont06 )
		oPrint:Say (0046,0165,"Cnpj" ,oFont06N,100)
		oPrint:Say (0056,0166,Transform(cCgcSM0,"@R 99.999.999/9999-99"),oFont06) //Cnpj do Benefici�rio
		BuzzBox  (0040,0250,0065,0350)	// Box Agencia / Codigo do Cedente
		oPrint:Say (0046, 0251,"Ag�ncia/C�digo de Cedente",oFont06N )

		If _cBanco = "399"
			oPrint:Say (0056, 0261,Substr(Alltrim(_cAgencia),1,4) + "/" + Alltrim(_cConta) + "-" + Alltrim(_cDvCta),oFont06,100)
		ElseIf _cBanco = "341"
			oPrint:Say (0056, 0261,Substr(Alltrim(_cAgencia),1,4) + "/" + Substr(Alltrim(_cConta),1,5) + "-" + Substr(Alltrim(_cDvCta),1,1),oFont06,100)
		ElseIf _cBanco = "237"
			oPrint:Say (0056, 0261,Substr(Alltrim(_cAgencia),1,4) + "-" + Substr(Alltrim(_cDvAge),1,1) + "/" + Padl(Substr(Alltrim(_cConta),1,7),7,"0") + "-" + Substr(Alltrim(_cDvCta),1,1),oFont06,100)
		Else
			oPrint:Say (0056, 0261,Substr(Alltrim(SEE->EE_CODCART),2,2) + "-" + Substr(Alltrim(_cAgencia),1,4) + "-" + Substr(Alltrim(_cAgencia),5,1) + "/" + Substr(Alltrim(_cConta),1,7) + "-" + Substr(Alltrim(_cConta),8,1),oFont06,100)
		EndIf

		BuzzBox  (0040,0350,0065,0450)	// N� do Documento
		oPrint:Say (0046, 0351,"N� do Documento",oFont06N )
		oPrint:Say (0056, 0361,SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA,oFont06 )
		BuzzBox  (0040,0450,0140,0560)	// Box de Selecao

		oPrint:Say (0050, 0451,"(  )Mudou-se"               ,oFont06N,100)
		oPrint:Say (0060, 0451,"(  )Ausente"                ,oFont06N,100)
		oPrint:Say (0070, 0451,"(  )N�o existe n� indicado"	,oFont06N,100)
		oPrint:Say (0080, 0451,"(  )Recusado"               ,oFont06N,100)
		oPrint:Say (0090, 0451,"(  )N�o procurado"          ,oFont06N,100)
		oPrint:Say (0100, 0451,"(  )Endere�o insuficiente"  ,oFont06N,100)
		oPrint:Say (0110, 0451,"(  )Desconhecido"           ,oFont06N,100)
		oPrint:Say (0120, 0451,"(  )Falecido"               ,oFont06N,100)
		oPrint:Say (0130, 0451,"(  )Outros(anotar no verso)",oFont06N,100)
		BuzzBox  (0065,0025,0090,0250)	// Box do Pagador
		oPrint:Say (0071, 0026,"Pagador",oFont06N )
		oPrint:Say (0081, 0026,Upper(SA1->A1_NOME),oFont06 )
		BuzzBox  (0065,0250,0090,0350)	// Box do Vencimento
		oPrint:Say (0071, 0251,"Vencimento",oFont06N )
		oPrint:Say (0081, 0301,Substr( DtoS(SE1->E1_VENCREA),7,2 ) + "/" + Substr( DtoS(SE1->E1_VENCREA),5,2 ) + "/" + Substr( DtoS(SE1->E1_VENCREA),1,4 ),oFont06 )
		BuzzBox  (0065,0350,0090,0450)	// Box do Valor do Documento
		oPrint:Say (0071, 0351,"Valor do Documento",oFont06N )
		oPrint:Say (0081, 0401,AllTrim(Transform(IIf(SE1->E1_PREFIXO<>"RPS",SE1->E1_SALDO ,SE1->E1_SALDO - (SE1->E1_CSLL + SE1->E1_COFINS + SE1->E1_PIS + SE1->E1_IRRF + SE1->E1_INSS)),"@E 999,999,999.99")),oFont06 )
		BuzzBox  (0090,0025,0140,0250)	// Box Recebi(emos) o Bloqueto / Titulo com as caracteristicas acima
		oPrint:Say (0107, 0026,"Box Recebi(emos) o Bloqueto / Titulo",oFont08N )
		oPrint:Say (0117, 0026,"com as caracteristicas acima",oFont08N )
		BuzzBox  (0090,0250,0115,0330)	// Box de Data
		oPrint:Say (0096, 0251,"Data",oFont06N )
		BuzzBox  (0090,0330,0115,0450)	// Box de Assinatura
		oPrint:Say (0096, 0331,"Assinatura",oFont06N )
		BuzzBox  (0115,0250,0140,0330)	// Box de Data
		oPrint:Say (0121, 0251,"Data",oFont06N )
		BuzzBox  (0115,0330,0140,0450)	// Box de Entregador
		oPrint:Say (0121, 0331,"Entregador",oFont06N )


		// 2� Parte
		oPrint:SayBitmap(0160,0025,_cBcoLogo,0085,0020)

		If _cBanco = "399"
			oPrint:Say(0176,0110, "|" + "399" + "-" + "9" + "|" ,oFont18N,100)	// C�digo do Banco + D�gito
		ElseIf _cBanco = "341"
			oPrint:Say(0176,0110, "|" + _cBanco + "-" + _cDigBanco + "|" ,oFont18N,100)	// C�digo do Banco + D�gito
		Else
			oPrint:Say(0176,0110, "|" + _cBanco + "-" + _cDigBanco + "|" ,oFont18N,100)	// C�digo do Banco + D�gito
		EndIf
		oPrint:Say (0176, 0470,"Recibo do Pagador",oFont12N )	// Recibo do Pagador
		BuzzBox  (0180,0025,0205,0425)	// Local de Pagamento
		oPrint:Say (0186, 0026,"Local de Pagamento",oFont06N )
		If _cBanco = "399"
			oPrint:Say (0196, 0096,"PAGAR PREFERENCIALMENTE EM AGENCIAS DO HSBC",oFont06N )
		ElseIf _cBanco = "341"
			oPrint:Say  (0191, 0096,"AT� O VENCIMENTO, PREFERENCIALMENTE NO ITA�",oFont06N )
			oPrint:Say  (0201, 0096,"AP�S O VENCIMENTO, SOMENTE NO ITA� ",oFont06N )
		ElseIf _cBanco = "237"
			oPrint:Say  (0196, 0096,"PAGAVEL PREFERENCIALMENTE NA REDE BRADESCO OU BRADESCO EXPRESSO",oFont06N )
		Else
			oPrint:Say  (0516, 0096,"PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO",oFont06N )
		EndIf
		BuzzBox  (0180,0425,0205,0560)	// Vencimento
		oPrint:Say (0186, 0426,"Vencimento",oFont06N )
		oPrint:Say (0196, 0476,Substr( DtoS(SE1->E1_VENCREA),7,2 ) + "/" + Substr( DtoS(SE1->E1_VENCREA),5,2 ) + "/" + Substr( DtoS(SE1->E1_VENCREA),1,4 ),oFont06 )
		BuzzBox  (0205,0025,0230,0425)	// Beneficiario
		oPrint:Say (0211, 0026,"Benefici�rio",oFont06N )
		oPrint:Say (0221, 0026,ALLTRIM(SM0->M0_NOMECOM),oFont06 )
		oPrint:Say (0211,0300,"Cnpj" ,oFont06N,100)
		oPrint:Say (0221,0301,Transform(cCgcSM0,"@R 99.999.999/9999-99"),oFont06) //Cnpj do Benefici�rio
		BuzzBox  (0205,0425,0230,0560)	// Agencia 	/ Codigo do Cedente
		oPrint:Say (0211, 0426,"Ag�ncia/C�digo de Cedente",oFont06N )
		If _cBanco = "399"
			oPrint:Say (0221, 0436,Substr(Alltrim(_cAgencia),1,4) + "/" + Alltrim(_cConta) + "-" + Alltrim(_cDvCta),oFont06,100)
		ElseIf _cBanco = "033"
			oPrint:Say (0221, 0436,Substr(Alltrim(_cAgencia),1,4)+"/"+Substr(Alltrim(_cCodEmp),9,7),oFont06,100)
		ElseIf _cBanco = "341"
			oPrint:Say (0221, 0436,Substr(Alltrim(_cAgencia),1,4) + "/" + Substr(Alltrim(_cConta),1,5) + "-" + Substr(Alltrim(_cDvCta),1,1),oFont06,100)
		ElseIf _cBanco = "237"
			oPrint:Say (0221, 0436,Substr(Alltrim(_cAgencia),1,4) + "-" + Substr(Alltrim(_cDvAge),1,1) + "/" + Padl(Substr(Alltrim(_cConta),1,7),7,"0") + "-" + Substr(Alltrim(_cDvCta),1,1),oFont06,100)
		Else
			oPrint:Say (0221, 0436,Substr(Alltrim(SEE->EE_CODCART),2,2) + "-" + Substr(Alltrim(_cAgencia),1,4) + "-" + Substr(Alltrim(_cAgencia),5,1) + "/" + Substr(Alltrim(_cConta),1,7) + "-" + Substr(Alltrim(_cConta),8,1),oFont06,100)
		EndIf
		BuzzBox  (0230,0025,0255,0100)	// Data do Documento
		oPrint:Say (0236, 0026,"Data do Documento",oFont06N )
		oPrint:Say (0246, 0056,Substr( DtoS(SE1->E1_EMISSAO),7,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),5,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),1,4 ),oFont06 )
		BuzzBox  (0230,0100,0255,0225)	// Nro. Documento + Parcela
		oPrint:Say (0236, 0101,"N� do Documento",oFont06N )
		oPrint:Say (0246, 0111,SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA,oFont06 )
		BuzzBox  (0230,0225,0255,0275)	// Especie Doc.
		oPrint:Say (0236, 0226,"Especie Doc.",oFont06N )
		If _cBanco $ "341/237"
			oPrint:Say (0246, 0246,"DM",oFont06 )
		Else
			oPrint:Say (0246, 0246,"PD",oFont06 )
		EndIf
		BuzzBox  (0230,0275,0255,0325)	// Aceite
		oPrint:Say (0236, 0276,"Aceite",oFont06N )
		oPrint:Say (0246, 0306,"N",oFont06 )
		BuzzBox  (0230,0325,0255,0425)	// Data do Processamento
		oPrint:Say (0236, 0326,"Data do Processamento",oFont06N )
		oPrint:Say (0246, 0356,Substr( DtoS(SE1->E1_EMISSAO),7,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),5,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),1,4 ),oFont06 )
		BuzzBox  (0230,0425,0255,0560)	// Nosso Numero
		oPrint:Say (0236, 0426,"Nosso Numero",oFont06N )
		If _cBanco = "033"
			oPrint:Say (0246, 0476, Substr(SE1->E1_NUMBCO,1,Len(Alltrim(SE1->E1_NUMBCO))-1) + " " + Right(AllTrim(SE1->E1_NUMBCO),1),oFont06 )
		ElseIf _cBanco = "341"
			oPrint:Say (0246, 0476,"109" + "/" + Substr(SE1->E1_NUMBCO,1,Len(Alltrim(SE1->E1_NUMBCO))-1) + "-" + Right(AllTrim(SE1->E1_NUMBCO),1),oFont06 )
		ElseIf _cBanco = "237"
			oPrint:Say (0246, 0476,Substr(Alltrim(_cCart),2,2) + If(Empty(_cCart),"","/") + Substr(SE1->E1_NUMBCO,1,Len(Alltrim(SE1->E1_NUMBCO))-1) + "-" + Right(AllTrim(SE1->E1_NUMBCO),1),oFont06 )
		Else
			oPrint:Say (0246, 0476,Alltrim(_cCart) + If(Empty(_cCart),"","/") + Substr(SE1->E1_NUMBCO,1,Len(Alltrim(SE1->E1_NUMBCO))-1) + "-" + Right(AllTrim(SE1->E1_NUMBCO),1),oFont06 )
		EndIf
		BuzzBox  (0255,0025,0280,0100)	// Uso do Banco
		oPrint:Say (0261, 0026,"Uso do Banco",oFont06N )
		BuzzBox  (0255,0100,0280,0165)	// Carteira
		oPrint:Say (0261, 0101,"Carteira",oFont06N )
		If _cBanco $ "341/399"
			oPrint:Say (0271, 0131,_cCart,oFont06 )
		Else
			oPrint:Say (0271, 0131,Substr(_cCart,2,2),oFont06 )
		EndIf
		BuzzBox  (0255,0165,0280,0225)	// Especie
		oPrint:Say (0261, 0166,"Especie",oFont06N )
		If _cBanco = "341/237"
			oPrint:Say (0271, 0186,"R$",oFont06N )
		Else
			oPrint:Say (0271, 0186,"REAL",oFont06N )
		EndIf
		BuzzBox  (0255,0225,0280,0325)	// Quantidade
		oPrint:Say (0261, 0226,"Quantidade",oFont06N )
		BuzzBox  (0255,0325,0280,0425)	// Valor
		oPrint:Say (0261, 0326,"Valor",oFont06N )
		BuzzBox  (0255,0425,0280,0560)	// Valor do Documento
		oPrint:Say (0261, 0426,"Valor do Documento",oFont06N )
		oPrint:Say (0271, 0476,AllTrim(Transform(IIf(SE1->E1_PREFIXO<>"RPS",SE1->E1_SALDO ,SE1->E1_SALDO  - (SE1->E1_CSLL + SE1->E1_COFINS + SE1->E1_PIS + SE1->E1_IRRF + SE1->E1_INSS)),"@E 999,999,999.99")),oFont06N )
		BuzzBox  (0280,0025,0380,0425)	// Instru��es (Todas as Informa��es deste Bloqueto s�o de Exclusiva Responsabilidade do Cedente)
		oPrint:Say (0286, 0026,"Instru��es (Todas as Informa��es deste Bloqueto s�o de Exclusiva Responsabilidade do Cedente)",oFont06N )
		oPrint:Say  (0316,0026,"Ap�s vencimento cobrar mora de R$ ..... " + Alltrim(Transform(((Iif(SE1->E1_PREFIXO<>"RPS",SE1->E1_SALDO,SE1->E1_SALDO - (SE1->E1_CSLL +SE1->E1_COFINS +SE1->E1_PIS +SE1->E1_IRRF +SE1->E1_INSS))* _nJuros)/100)/30,"@E 99,999,999.99"))+ " ao dia", oFont08,100)
		oPrint:Say  (0326,0026,"Ap�s " + DtoC(SE1->E1_VENCREA) + " cobrar multa de R$ " + Alltrim(Transform(((Iif(SE1->E1_PREFIXO<>"RPS",SE1->E1_SALDO,SE1->E1_SALDO - (SE1->E1_CSLL +SE1->E1_COFINS +SE1->E1_PIS +SE1->E1_IRRF +SE1->E1_INSS))* _nMulta)/100),"@E 99,999,999.99")), oFont08,100)
		oPrint:Say  (0336,0026,"Protestar apos " + _cProtesto + " dias �teis do vencimento.", oFont08,100)
		If !Empty(SE1->E1_DECRESC)
			oPrint:Say  (0346,0026,"Conceder Desconto de R$ ..... " + AllTrim(Transform((SE1->E1_DECRESC),"@E 99,999,999.99")), oFont08,100)
		EndIf
		If !Empty(SE1->E1_XABATIM)
			oPrint:Say  (0356,0026,"Conceder Abatimento de R$ ..... " + AllTrim(Transform((SE1->E1_XABATIM),"@E 99,999,999.99")), oFont08,100)
		EndIf
		BuzzBox  (0280,0425,0300,0560)	// (-) Desconto / Abatimento
		oPrint:Say (0286, 0426,"(-) Desconto / Abatimento",oFont06N )
		BuzzBox  (0300,0425,0320,0560)	// (-) Outras Dedu��es
		oPrint:Say (0306, 0426,"(-) Outras Dedu��es",oFont06N )
		BuzzBox  (0320,0425,0340,0560)	// (+) Mora / Multa
		oPrint:Say (0326, 0426,"(+) Mora / Multa",oFont06N )
		BuzzBox  (0340,0425,0360,0560)	// (+) Outros Acrescimos
		oPrint:Say (0346, 0426,"(+) Outros Acrescimos",oFont06N )
		BuzzBox  (0360,0425,0380,0560)	// (=) Valor Cobrado
		oPrint:Say (0366, 0426,"(=) Valor Cobrado",oFont06N )
		BuzzBox  (0380,0025,0450,0560)	// Pagador / Pagador Avalista
		oPrint:Say (0386, 0026,"Pagador",oFont06N )
		oPrint:Say  (0396,0106,Upper(SA1->A1_NOME),oFont06 ,100)
		oPrint:Say  (0406,0106,SA1->(If(Empty(A1_ENDCOB),A1_END,A1_ENDCOB) + " " + If(Empty(SA1->A1_BAIRROC),SA1->A1_BAIRRO,SA1->A1_BAIRROC)),oFont08 ,100)
		oPrint:Say  (0416,0106,SA1->(If(Empty(SA1->A1_CEPC),SA1->A1_CEP,SA1->A1_CEPC) + " " + If(Empty(SA1->A1_MUNC),SA1->A1_MUN,SA1->A1_MUNC) + " " + If(Empty(SA1->A1_ESTC),SA1->A1_EST,SA1->A1_ESTC)),oFont08 ,100)
		oPrint:Say  (0426,0106,SA1->(Transform(Alltrim(SM0->M0_CGC),PesqPict("SA1","A1_CGC")) + "               " + A1_INSCR),oFont08 ,100)
		oPrint:Say (0448, 0026,"Pagador Avalista",oFont08N )
		oPrint:Say  (0455,0360,"Autentica��o Mec�nica",oFont06,100)



		// 3� Parte
		oPrint:SayBitmap(0480,0025,_cBcoLogo,0085,0020)
		_cCodBar := Alltrim(SE1->E1_CODBAR)
		_cNumBol := Alltrim(SE1->E1_CODDIG)
		If _cBanco = "033"
			_cCodBarLit := Left(_cNumBol,5)+"."+Substr(_cNumBol,6,5)+"   "+;
			Substr(_cNumBol,11,5)+"."+Substr(_cNumBol,16,6)+"   "+;
			Substr(_cNumBol,22,5)+"."+Substr(_cNumBol,27,6)+"   "+;
			Substr(_cNumBol,33,1)+"   "+;
			Substr(_cNumBol,34)
		Else
			_cCodBarLit := Left(_cNumBol,5)+"."+Substr(_cNumBol,6,5)+"   "+;
			Substr(_cNumBol,11,5)+"."+Substr(_cNumBol,16,6)+"   "+;
			Substr(_cNumBol,22,5)+"."+Substr(_cNumBol,27,6)+"   "+;
			Substr(_cNumBol,33,1)+"   "+;
			Substr(_cNumBol,34)
		EndIf
		oPrint:Say(0496,0200,_cCodBarLit,oFont14N,100)
		If _cBanco = "399"
			oPrint:Say(0496,0110, "|" + "399" + "-" + "9" + "|" ,oFont18N,100)	// C�digo do Banco + D�gito
		ElseIf _cBanco = "341"
			oPrint:Say(0496,0110, "|" + _cBanco + "-" + _cDigBanco + "|" ,oFont18N,100)	// C�digo do Banco + D�gito
		Else
			oPrint:Say(0496,0110, "|" + _cBanco + "-" + _cDigBanco + "|" ,oFont18N,100)	// C�digo do Banco + D�gito
		EndIf
		BuzzBox  (0500,0025,0525,0425)	// Local de Pagamento
		oPrint:Say (0506, 0026,"Local de Pagamento",oFont06N )
		If _cBanco = "399"
			oPrint:Say (0516, 0096,"PAGAR PREFERENCIALMENTE EM AGENCIAS DO HSBC",oFont06N )
		ElseIf _cBanco = "341"
			oPrint:Say  (0511, 0096,"AT� O VENCIMENTO, PREFERENCIALMENTE NO ITA�",oFont06N )
			oPrint:Say  (0521, 0096,"AP�S O VENCIMENTO, SOMENTE NO ITA� ",oFont06N )
		ElseIf _cBanco = "237"
			oPrint:Say  (0516, 0096,"PAGAVEL PREFERENCIALMENTE NA REDE BRADESCO OU BRADESCO EXPRESSO",oFont06N )
			//oPrint:Say  (0526, 0096,"AP�S O VENCIMENTO, SOMENTE NAS AGENCIAS DO BRADESCO",oFont06N )
		Else
			oPrint:Say  (0516, 0096,"PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO",oFont06N )
		EndIf
		BuzzBox  (0500,0425,0525,0560)	// Vencimento
		oPrint:Say (0506, 0426,"Vencimento",oFont06N )
		oPrint:Say (0516, 0476,Substr( DtoS(SE1->E1_VENCTO),7,2 ) + "/" + Substr( DtoS(SE1->E1_VENCTO),5,2 ) + "/" + Substr( DtoS(SE1->E1_VENCTO),1,4 ),oFont06 )
		BuzzBox  (0525,0025,0550,0425)	// Beneficiario
		oPrint:Say (0531, 0026,"Benefici�rio",oFont06N )
		oPrint:Say (0541, 0026,ALLTRIM(SM0->M0_NOMECOM),oFont06 )
		oPrint:Say (0531,0300,"Cnpj" ,oFont06N,100)
		oPrint:Say (0541,0301,Transform(cCgcSM0,"@R 99.999.999/9999-99"),oFont06) //Cnpj do Benefici�rio
		BuzzBox  (0525,0425,0550,0560)	// Agencia / Codigo do Cedente
		oPrint:Say (0531, 0426,"Ag�ncia/C�digo de Cedente",oFont06N )
		//oPrint:Say (0541, 0426,Substr(Alltrim(_cAgencia),1,4) + "-" + Alltrim(_cDvAge) + "/" + Alltrim(_cConta) + "-" + Alltrim(_cDvCta),oFont06,100)
		If _cBanco = "399"
			oPrint:Say (0541, 0436,Substr(Alltrim(_cAgencia),1,4) + "/" + Alltrim(_cConta) + "-" + Alltrim(_cDvCta),oFont06,100)
		ElseIf _cBanco = "033"
			oPrint:Say (0541, 0436,Substr(Alltrim(_cAgencia),1,4)+"/"+Substr(Alltrim(_cCodEmp),9,7),oFont06,100)
		ElseIf _cBanco = "341"
			oPrint:Say (0541, 0436,Substr(Alltrim(_cAgencia),1,4) + "/" + Substr(Alltrim(_cConta),1,5) + "-" + Substr(Alltrim(_cDvCta),1,1),oFont06,100)
		ElseIf _cBanco = "237"
			oPrint:Say (0541, 0436,Substr(Alltrim(_cAgencia),1,4) + "-" + Substr(Alltrim(_cDvAge),1,1) + "/" + Padl(Substr(Alltrim(_cConta),1,7),7,"0") + "-" + Substr(Alltrim(_cDvCta),1,1),oFont06,100)
		Else
			oPrint:Say (0541, 0436,Substr(Alltrim(SEE->EE_CODCART),2,2) + "-" + Substr(Alltrim(_cAgencia),1,4) + "-" + Substr(Alltrim(_cAgencia),5,1) + "/" + Substr(Alltrim(_cConta),1,7) + "-" + Substr(Alltrim(_cConta),8,1),oFont06,100)
		EndIf
		BuzzBox  (0550,0025,0575,0100)	// Data do Documento
		oPrint:Say (0556, 0026,"Data do Documento",oFont06N )
		oPrint:Say (0566, 0046,Substr( DtoS(SE1->E1_EMISSAO),7,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),5,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),1,4 ),oFont06 )
		BuzzBox  (0550,0100,0575,0225)	// Nro. Documento + Parcela
		oPrint:Say (0556, 0101,"N� do Documento",oFont06N )
		oPrint:Say (0566, 0111,SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA,oFont06 )
		BuzzBox  (0550,0225,0575,0275)	// Especie Doc.
		oPrint:Say (0556, 0226,"Especie Doc.",oFont06N )
		If _cBanco $ "341/237"
			oPrint:Say (0566, 0246,"DM",oFont06 )
		Else
			oPrint:Say (0566, 0246,"PD",oFont06 )
		EndIf
		BuzzBox  (0550,0275,0575,0325)	// Aceite
		oPrint:Say (0556, 0276,"Aceite",oFont06N )
		oPrint:Say (0566, 0296,"N",oFont06 )
		BuzzBox  (0550,0325,0575,0425)	// Data do Processamento
		oPrint:Say (0556, 0326,"Data do Processamento",oFont06N )
		oPrint:Say (0566, 0356,Substr( DtoS(SE1->E1_EMISSAO),7,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),5,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),1,4 ),oFont06 )
		BuzzBox  (0550,0425,0575,0560)	// Nosso Numero
		oPrint:Say (0556, 0426,"Nosso Numero",oFont06N )
		//oPrint:Say (0566, 0426,Alltrim(SEE->EE_CODCART) + If(Empty(SEE->EE_CODCART),"","/") + Substr(SE1->E1_NUMBCO,1,Len(Alltrim(SE1->E1_NUMBCO))-1) + "-" + Right(AllTrim(SE1->E1_NUMBCO),1),oFont06 )
		If (_cBanco == "033") .or. (_cBanco == "399")
			oPrint:Say (0566, 0476,Substr(SE1->E1_NUMBCO,1,Len(Alltrim(SE1->E1_NUMBCO))-1) + " " + Right(AllTrim(SE1->E1_NUMBCO),1),oFont06 )
		ElseIf _cBanco = "341"
			oPrint:Say (0566, 0476,"109" + "/" + Substr(SE1->E1_NUMBCO,1,Len(Alltrim(SE1->E1_NUMBCO))-1) + "-" + Right(AllTrim(SE1->E1_NUMBCO),1),oFont06 )
		ElseIf _cBanco = "237"
			oPrint:Say (0566, 0476,Substr(Alltrim(_cCart),2,2) + If(Empty(_cCart),"","/") + Substr(SE1->E1_NUMBCO,1,Len(Alltrim(SE1->E1_NUMBCO))-1) + "-" + Right(AllTrim(SE1->E1_NUMBCO),1),oFont06 )
		Else
			oPrint:Say (0566, 0476,Alltrim(_cCart) + If(Empty(_cCart),"","/") + Substr(SE1->E1_NUMBCO,1,Len(Alltrim(SE1->E1_NUMBCO))-1) + "-" + Right(AllTrim(SE1->E1_NUMBCO),1),oFont06 )
		EndIf
		BuzzBox  (0575,0025,0600,0100)	// Uso do Banco
		oPrint:Say (0581, 0026,"Uso do Banco",oFont06N )
		BuzzBox  (0575,0100,0600,0165)	// Carteira
		oPrint:Say (0581, 0101,"Carteira",oFont06N )
		If _cBanco $ "341/399"
			oPrint:Say (0591, 0131,_cCart,oFont06 )
		Else
			oPrint:Say (0591, 0131,Substr(_cCart,2,2),oFont06 )
		EndIf
		BuzzBox  (0575,0165,0600,0225)	// Especie
		oPrint:Say (0581, 0166,"Especie",oFont06N )
		If _cBanco $ "341/237"
			oPrint:Say (0591, 0186,"R$",oFont06N )
		Else
			oPrint:Say (0591, 0186,"REAL",oFont06N )
		EndIf
		BuzzBox  (0575,0225,0600,0325)	// Quantidade
		oPrint:Say (0581, 0226,"Quantidade",oFont06N )
		BuzzBox  (0575,0325,0600,0425)	// Valor
		oPrint:Say (0581, 0326,"Valor",oFont06N )
		BuzzBox  (0575,0425,0600,0560)	// Valor do Documento
		oPrint:Say (0581, 0426,"Valor do Documento",oFont06N )
		oPrint:Say (0591, 0476,AllTrim(Transform(IIf(SE1->E1_PREFIXO<>"RPS",SE1->E1_SALDO ,SE1->E1_SALDO - (SE1->E1_CSLL + SE1->E1_COFINS + SE1->E1_PIS + SE1->E1_IRRF + SE1->E1_INSS)),"@E 999,999,999.99")),oFont06N )
		BuzzBox  (0600,0025,0700,0425)	// Instru��es (Todas as Informa��es deste Bloqueto s�o de Exclusiva Responsabilidade do Cedente)
		oPrint:Say (0606, 0026,"Instru��es (Todas as Informa��es deste Bloqueto s�o de Exclusiva Responsabilidade do Cedente)",oFont06N )
		oPrint:Say  (0636,0026,"Ap�s vencimento cobrar mora de R$ ..... " + Alltrim(Transform(((Iif(SE1->E1_PREFIXO<>"RPS",SE1->E1_SALDO ,SE1->E1_SALDO - (SE1->E1_CSLL +SE1->E1_COFINS +SE1->E1_PIS +SE1->E1_IRRF +SE1->E1_INSS))* _nJuros)/100)/30,"@E 99,999,999.99"))+ " ao dia", oFont08,100)
		oPrint:Say  (0646,0026,"Ap�s " + DtoC(SE1->E1_VENCREA) + " cobrar multa de R$ " + Alltrim(Transform(((Iif(SE1->E1_PREFIXO<>"RPS",SE1->E1_SALDO, SE1->E1_SALDO  - (SE1->E1_CSLL +SE1->E1_COFINS +SE1->E1_PIS +SE1->E1_IRRF +SE1->E1_INSS))* _nMulta)/100),"@E 99,999,999.99")), oFont08,100)
		oPrint:Say  (0656,0026,"Protestar apos " + _cProtesto + " dias �teis do vencimento.", oFont08,100)
		If !Empty(SE1->E1_DECRESC)
			oPrint:Say  (0666,0026,"Conceder Desconto de R$ ..... " + AllTrim(Transform((SE1->E1_DECRESC),"@E 99,999,999.99")), oFont08,100)
		EndIf
		If !Empty(SE1->E1_XABATIM)
			oPrint:Say  (0676,0026,"Conceder Abatimento de R$ ..... " + AllTrim(Transform((SE1->E1_XABATIM),"@E 99,999,999.99")), oFont08,100)
		EndIf
		BuzzBox  (0600,0425,0620,0560)	// (-) Desconto / Abatimento
		oPrint:Say (0606, 0426,"(-) Desconto / Abatimento",oFont06N )
		BuzzBox  (0620,0425,0640,0560)	// (-) Outras Dedu��es
		oPrint:Say (0626, 0426,"(-) Outras Dedu��es",oFont06N )
		BuzzBox  (0640,0425,0660,0560)	// (+) Mora / Multa
		oPrint:Say (0646, 0426,"(+) Mora / Multa",oFont06N )
		BuzzBox(0660,0425,0680,0560)	// (+) Outros Acrescimos
		oPrint:Say(0666, 0426,"(+) Outros Acrescimos",oFont06N )
		BuzzBox(0680,0425,0700,0560)	// (=) Valor Cobrado
		oPrint:Say(0686, 0426,"(=) Valor Cobrado",oFont06N )
		BuzzBox(0700,0025,0770,0560)	// Pagador / Pagador Avalista
		oPrint:Say(0706, 0026,"Pagador",oFont06N )
		oPrint:Say(0716,0106,Upper(SA1->A1_NOME),oFont08 ,100)
		oPrint:Say(0726,0106,SA1->(If(Empty(A1_ENDCOB),A1_END,A1_ENDCOB) + " " + If(Empty(SA1->A1_BAIRROC),SA1->A1_BAIRRO,SA1->A1_BAIRROC)),oFont08 ,100)
		oPrint:Say(0736,0106,SA1->(If(Empty(SA1->A1_CEPC),SA1->A1_CEP,SA1->A1_CEPC) + " " + If(Empty(SA1->A1_MUNC),SA1->A1_MUN,SA1->A1_MUNC) + " " + If(Empty(SA1->A1_ESTC),SA1->A1_EST,SA1->A1_ESTC)),oFont08 ,100)
		oPrint:Say(0746,0106,SA1->(Transform(Alltrim(SM0->M0_CGC),PesqPict("SA1","A1_CGC")) + "               " + A1_INSCR),oFont08 ,100)
		oPrint:Say(0768, 0026,"Pagador Avalista",oFont06N )
		oPrint:Say(0775,0350,"Autentica��o Mec�nica - Ficha de Compensa��o",oFont06,100)
		oPrint:FWMSBAR("INT25",66.2,2.0,_cCodBar,oPrint,.F.,,,,1.0,,,,.F.)  //28.0
		oPrint:EndPage()
		oPrint:Print()

		if File(cFileName)
		   _nArqAbr++
		   // Envio de Email
		   if (SA1->A1_BLEMAIL == '1')
		     if !Empty(SA1->A1_EMAIL)
		      aAdd(aEmail, {aVetor[i,3],;		// Titulo
		       				cFileName,;			// Caminho + Arquivo
		       				SA1->A1_EMAIL;		// e-mail
		      				} )
		     else
		       // Registra mensagem de alerta
		     	aAdd(aError,{SA1->A1_FILIAL+SA1->A1_COD+SA1->A1_LOJA,'Filial: '+SA1->A1_FILIAL+' Cliente: '+SA1->A1_COD+' Loja: '+SA1->A1_LOJA+ 'Mensagem: Cliente sem e-mail'})
		     endif
		   Endif
		Endif
	EndIf
Next

if Len(aEmail) > 0
	For nX := 1 to Len(aEmail)
	    // Verifica se existe o diretorio para envio do e-mail
	    oObj:IncRegua2("Enviando boleto, Titulo: "+aEmail[nX,1]+" por e-mail" )
	    cArq     := ''
	    cFileName:= aEmail[nX,2]
	    cArq     := RETARQUIVO(cFileName,2)
	    cOrigem  := ''
	    cOrigem  := RETARQUIVO(cFileName,1)
	    cDestino := ''
	    cDestino := cPath+"EMail"

	    // Copia da maquina local para a system
	    CPYT2S(cFileName, cDestino,.T.)

		cDestino  := '\system\EMail\' + cArq

	    cHtml := CorpoEmail()
		//oEmail := SENDMAIL():New( 'valdemir.jose@totvs.com.br', aEmail[nX,3],'', '', 'BOLETO', cDestino, cHtml )

		u_EnviarMail(cDestino, 'Boleto', cHtml, aEmail[nX,3])

		//if oEmail:Send()
		   _nEmail++
		   if file(cDestino)
		      fErase( cDestino )
		   Endif
		//Endif
		//FreeObj(oEmail)
	Next

	if Len(aError) > 0
	   cMsgError := ''
	   For nY := 1 to Len(aError)
	   	   cMsgError += aError[2] + CRLF
	   Next
	   apMsgInfo(cMsgError, 'Aten��o!!!')
	Endif

Endif

if _nEmail > 0
	MsgRun('Boleto(s) enviado por e-mail com sucesso!!!',,{|| Sleep(2000) })
	_nEmail := 0
Endif

Return






/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AddBordero�Autor  �Eduardo/Valdemir    � Data �  06/08/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera Bordero com base nos titulos selecionados             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � EV Solucoes Inteligentes									  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AddBordero(aVetor)
Local cNumBor := ""
Local nRegis  := 0
Local lRET    := .T.

	aEval(aVetor, { |x| if(x[1]=.T.,nRegis++,0) })

	if oObj !=nil
		oObj:SetRegua1( Len(aVetor) )
		oObj:SetRegua2( nRegis )
	Endif

	cNumBor := GetNumBor()
/*
	If SEE->( DbSeek( xFilial("SEE")+ _cBanco + _cAgencia + _cConta) )
		RecLock("SEE",.F.)  //Prepara Registro para Alteracao
		SEE->EE_DTGERAC 	:=  dDataBase
		MsUnlock()
	EndIf
*/
	lBordero := .F.
	//�������������������������������������������������������������������������Ŀ
	//�Gera todos o Numero do Bordero na Tabela SE1		                        �
	//���������������������������������������������������������������������������
	For nTit := 1 to Len(aVetor)
	    oObj:IncRegua1("Processando, Carregando informa��es para Bordero " )
	    // Verifica se foi feito ajuste no boleto, caso tenha sido feito
		If aVetor[nTit][1] .and. (!aVetor[nTit][20]) 				// Gravar somente os itens marcados
			DbSelectArea("SE1")
			DbSetOrder(1)
			DbGoTop()         //    Filial         // Prefixo         // Titulo          // Parcela          // Tipo
			If SE1->( DbSeek( xFilial("SE1")+ aVetor[nTit][2] + aVetor[nTit][3] + aVetor[nTit][4] + aVetor[nTit][12]) )
				Begin Transaction
				  IF EMPTY(SE1->E1_NUMBOR)
					RecLock("SEA",.T.)
					SEA->EA_TRANSF  := "S"
				 	SEA->EA_FILIAL  := xFilial()
					SEA->EA_NUMBOR  := cNumBor
					SEA->EA_DATABOR := dDataBase
					SEA->EA_PORTADO := _cBanco
					SEA->EA_AGEDEP  := _cAgencia
					SEA->EA_NUMCON  := _cConta
					SEA->EA_NUM     := SE1->E1_NUM
					SEA->EA_PARCELA := IF(EMPTY(SE1->E1_PARCELA),'',SE1->E1_PARCELA)
					SEA->EA_PREFIXO := SE1->E1_PREFIXO
					SEA->EA_TIPO	:= SE1->E1_TIPO
					SEA->EA_CART    := "R"
					SEA->EA_SITUACA := '1' //SE1->E1_SITUACA
					SEA->EA_SITUANT := '1' //SE1->E1_SITUACA
					IF FieldPos("EA_FILORIG") > 0
						SEA->EA_FILORIG := SE1->E1_FILIAL
					Endif
                    MsUnlock()
                    // Se n�o foi emitido o bordero atualiza o campo
                    if Empty(SE1->E1_NUMBOR)
			 			RecLock("SE1",.F.)  //Prepara Registro para Alteracao
						SE1->E1_NUMBOR 	:= cNumBor
						SE1->E1_DATABOR	:= dDatabase
						SE1->E1_SITUACA := SEA->EA_SITUACA
						SE1->E1_PORTADO	:= _cBANCO
						SE1->E1_AGEDEP	:= _cAGENCIA
						SE1->E1_CONTA	:= _cCONTA
						MsUnlock()
					endif
					if !lBordero
						lBordero := .T.
					endif
                  Endif
				End Transaction
				MsUnlock()
			    oObj:IncRegua2("Gerando o bordero N� "+ cNumBor+" Titulo: "+SE1->E1_NUM)
			EndIf
		EndIf
	Next
	// Gera CNAB
	if lBordero
	    U_Bordero(cNumbor)
    	GeraCNAB(cNumBor)
    	_nArqAbr++
    endif

Return





/*��������������������������������������������������������������������������������������
���Programa � BuzzBox         �Autor�                            � Data � 24/04/2013 ���
������������������������������������������������������������������������������������͹��
���Descricao� Desenha um Box Sem Preenchimento                                       ���
��������������������������������������������������������������������������������������*/
Static Function BuzzBox(_nLinIni,_nColIni,_nLinFin,_nColFin) // < nRow>, < nCol>, < nBottom>, < nRight>
	oPrint:Line( _nLinIni,_nColIni,_nLinIni,_nColFin,CLR_BLACK, "-2")
	oPrint:Line( _nLinFin,_nColIni,_nLinFin,_nColFin,CLR_BLACK, "-2")
	oPrint:Line( _nLinIni,_nColIni,_nLinFin,_nColIni,CLR_BLACK, "-2")
	oPrint:Line( _nLinIni,_nColFin,_nLinFin,_nColFin,CLR_BLACK, "-2")
Return




/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �GetNumBor �Autor  � Valdemir Jose      � Data � 07/08/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorno o numero do proximo bordero.  					  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � EV Solucoes Inteligentes									  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function GetNumBor()
Local cNumBor := Space(6)

cNumBor := Soma1(GetMV("MV_NUMBORR"),6)
cNumBor := Replicate("0",6-Len(Alltrim(cNumBor)))+Alltrim(cNumBor)

While !MayIUseCode("SE1"+xFilial("SE1")+cNumBor)  //verifica se esta na memoria, sendo usado
	// busca o proximo numero disponivel
	cNumBor := Soma1(cNumBor)
EndDo


//��������������������������������������������������������������Ŀ
//� Grava o N�mero do bordero atualizado						 �
//� Posicionar no sx6 sempre usando GetMv. N�o utilize Seek !!!  �
//����������������������������������������������������������������
dbSelectArea("SX6")
PutMv("MV_NUMBORR",cNumBor)

Return cNumBor




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GeraCNAB  �Autor  �Eduardo/Valdemir    � Data �  18/08/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera Arquivo CNAB                                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � EV Solucoes Inteligentes									  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GeraCNAB(pcNumBor)
Local cPerg		  := "AFI150"
Private lPanelFin := .F.
Private nPosAuto  := .T.
Private aBordero  := {}
//��������������������������������������Ŀ
//� Variaveis utilizadas para parametros  �
//� mv_par01		 // Do Bordero 		  �
//� mv_par02		 // Ate o Bordero 	  �
//� mv_par03		 // Arq.Config 		  �
//� mv_par04		 // Arq. Saida    	  �
//� mv_par05		 // Banco     		  �
//� mv_par06		 // Agenciao     	  �
//� mv_par07		 // Conta   		  �
//� mv_par08		 // Sub-Conta  		  �
//� mv_par09		 // Cnab 1 / Cnab 2   �
//� mv_par10		 // Considera Filiais �
//� mv_par11		 // De Filial   	  �
//� mv_par12		 // Ate Filial        �
//� mv_par13		 // Quebra por ?	  �
//� mv_par14		 // Seleciona Filial? �
//�����������������������������������������


	MV_PAR01 := pcNumBor
	MV_PAR02 := pcNumBor

	IF _cBanco $ '033/237/341/422/745'
		MV_PAR03 := UPPER(_cBanco+'.REM')
	elseif _cBanco $ '001/033/422/745'
		MV_PAR03 := UPPER(_cBanco+'.2re')
	Endif

	MV_PAR04 := 'C:\EVAUTO\AReceber\Cnabs\'+_cBanco+'cob'+DTOS(DDATABASE)
	MV_PAR05 := _cBanco
	MV_PAR06 := _cAgencia
	MV_PAR07 := _cConta
	MV_PAR08 := _cSubcta
	MV_PAR09 := if(RIGHT(ALLTRIM(MV_PAR03),3)='2RE',2,1)
	MV_PAR10 := 2
	MV_PAR11 := ''
	MV_PAR12 := 'ZZ'
	MV_PAR13 := 3
	MV_PAR14 := 2

	//fa150Gera("SE1")
	u_EV150Gera("SE1")

	if File(MV_PAR04)
	   _nArqAbr++
		MsgRun('Arquivo CNAB Gerado Sucesso!!!',,{|| Sleep(2000) })
	Endif


Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LIBGERVAL �Autor  �Valdemir Jose       � Data �  05/09/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
���Parametro � pCompleto - Caminho com arquivo                            ���
���          � nTipo     - 1 = Caminho 2 = Arquivo                        ���
�������������������������������������������������������������������������͹��
���Retorno   � Caracter, podendo ser (Caminho / Arquivo)                  ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RETARQUIVO(pCompleto,nTipo)
	Local cRET := ""
	Local nX   := 1
	Local cTMP := ""

	For nX := Len(pCompleto) to 1 step -1
	    if nTipo = 1
	      if Substr(pCompleto,nX,1) = '\'
	      	cRET := Substr(pCompleto,1,nX-1)
	      	exit
	      endif
	    Else
	      if Substr(pCompleto,nX,1) != '\'
	       cTMP := Substr(pCompleto,nX,Len(pCompleto))
	       cRET := cTMP
	      else
	       exit
	      endif
	    Endif
	Next
Return cRET



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BOLETOS   �Autor  �Valdemir  / Eduardo � Data �  22/09/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta o corpo do e-mail                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � EV Solucoes Inteligentes                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CorpoEmail()
	Local cRET := ''

	cRET += "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'> " + cENTER
	cRET += "<html xmlns='http://www.w3.org/1999/xhtml'>" + cENTER
	cRET += "<head>" + cENTER
	cRET += "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' />" + cENTER
	cRET += "<title>CNAB FACIL</title>" + cENTER
	cRET += "<style type='text/css'>" + cENTER
	cRET += "<!--" + cENTER
	cRET += ".style1 {" + cENTER
	cRET += "	color: #FFFFFF;" + cENTER
	cRET += "	font-size: 24px;" + cENTER
	cRET += "}" + cENTER
	cRET += ".style2 {" + cENTER
	cRET += "	color: #0000FF;" + cENTER
	cRET += "	font-weight: bold;" + cENTER
	cRET += "}" + cENTER
	cRET += ".style3 {" + cENTER
	cRET += "	color: #FF0000;" + cENTER
	cRET += "	font-weight: bold;" + cENTER
	cRET += "	font-size: 10px;" + cENTER
	cRET += "	font-family: Arial, Helvetica, sans-serif;" + cENTER
	cRET += "}" + cENTER
	cRET += "-->" + cENTER
	cRET += "</style>" + cENTER
	cRET += "</head>" + cENTER

	cRET += "<body>" + cENTER
	cRET += "<form id='EV' name='EV' method='post' action=''>" + cENTER
	cRET += "  <table width='655' border='0' cellspacing='4' bgcolor='#FFFFB0'>" + cENTER
	cRET += "    <tr>" + cENTER
	cRET += "      <th colspan='3' bgcolor='#000099'><div align='center' class='style1'>" +SM0->M0_NOME+ " </div></th>" + cENTER
	cRET += "    </tr>" + cENTER
	cRET += "    <tr>" + cENTER
	cRET += "      <td width='160'>&nbsp;</td>" + cENTER
	cRET += "      <td width='11'>&nbsp;</td>" + cENTER
	cRET += "      <td width='462'>&nbsp;</td>" + cENTER
	cRET += "    </tr>" + cENTER
	cRET += "    <tr>" + cENTER
	cRET += "      <td colspan='3'>Segue o boleto em anexo. </td>" + cENTER
	cRET += "    </tr>" + cENTER
	cRET += "    <tr>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "    </tr>" + cENTER
	cRET += "    <tr>" + cENTER
	cRET += "      <td><div align='right'><strong>Referente:</strong></div></td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "    </tr>" + cENTER
	cRET += "    <tr>" + cENTER
	cRET += "      <td><p align='right'>Titulo:</p>      </td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "      <td><span class='style2'>" + Alltrim(SE1->E1_NUM) + "</span></td>" + cENTER
	cRET += "    </tr>" + cENTER
	cRET += "    <tr>" + cENTER
	cRET += "      <td><div align='right'>Parcela:</div></td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "      <td><span class='style2'>"+ SE1->E1_PARCELA + "</span></td>" + cENTER
	cRET += "    </tr>" + cENTER
	cRET += "    <tr>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "    </tr>" + cENTER
	cRET += "    <tr>" + cENTER
	cRET += "      <td>Atenciosamente</td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "    </tr>" + cENTER
	cRET += "    <tr>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "    </tr>" + cENTER
	cRET += "    <tr>" + cENTER
	cRET += "      <td>Equipe Depto.Financeiro</td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "    </tr>" + cENTER
	cRET += "    <tr>" + cENTER
	cRET += "    <tr>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "      <td>&nbsp;</td>" + cENTER
	cRET += "    </tr>" + cENTER
	cRET += "    <tr>" + cENTER
	cRET += "      <td colspan='3'><div align='center'><span class='style3'>Envio autom&aacute;tico - &lt; CNAB F&Aacute;CIL Protheus &gt;</span> </div></td>" + cENTER
	cRET += "    </tr>" + cENTER
	cRET += "  </table>" + cENTER
	cRET += "</form>" + cENTER
	cRET += "</body>" + cENTER
	cRET += "</html>" + cENTER

Return cRET