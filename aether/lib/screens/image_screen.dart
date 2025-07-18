import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aether/repositories/content
s.dart';
import 'package:aether/widgets/breadcrumb_';

clWidget {
  final String imageId;
  
  const Ima

 
;
}

class _ImageScreenState e
  m;
  bool _isL;
  bool _showMetadata;
  final Transformationler();
  
  @
  {
    super.initState();
    _loadImage();
  }
  
  @override
  void dispose() {
    _transformationController.d();
    super.dispose();
  }
  
  Future<void> _loaasync {
    try {
      fin);
     
    
  ull) {
        set(() {
          _imageItem = imageItem;
          _isLoadingfalse;
        });
      } else {
        // Image n
        if (mounted) {
          context.pop();
        }
      }
    } catch (e{
      setStae(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          Snac $e')),
        );
      }
    }
  }
  
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      
    );
  }
  
  Widget _buildImat() {
    return SafeArea(
      child: Column(
        mainAxisSmin,
        children: [
          ListTile(
            leading: Icon(
            title: Text(_iorites'),
            onTap: () {
              Navigator.pop(context);
              _toggleFavorite();
            },
          ),
          Li
          t),
        '),
            onTap: () {
              Navi);
              _showRenameDialog();
            },
          ),
          ListTile(
            leading: co),
            title: ils'),
            onTap: () {
              Navigator.pop(context);
              se) {
                _showMetadata = !_showMetadata;
              });
            },
          ),
          ListTie(
            leading: const Icon(Icons.sh
            title: ge'),
            onTap: () {
              Navigator.pop(context);
              _s;
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_copy),
            titlge'),
            on() {
            text);
          age();
        
      
   
  elete),
            title: const Text('Move t),
            onTap: () {
              Navigator.
              _moveToTrash();
            },
          ),
        ],
      ),
    );
  }
  
  ync {
    if (_imageItem == null) return;
    
   
 ;
  }
} '0')}').padLeft(2,tring(te.toS:${date.minuour}e.h${dat{date.year} ate.month}/$te.day}/${durn '${da    ret {
e date)(DateTimtetDa _forma
  String }
  }
  
   B';ixed(1)} GtoStringAsF24 * 1024)).1024 * 10ytes / (${(breturn ' {
      else    } d(1)} MB';
sFixengAtri024)).toS* 124  / (10rn '${(bytes      retu024) {
24 * 1 1024 * 10tes <e if (by  } elsB';
  1)} KFixed(tringAstoS1024). / rn '${(bytes retu
     4 * 1024) {ytes < 102 else if (b    }tes B';
rn '$bytu
      rees < 1024) { if (byt {
   e(int bytes)tFileSizrma _fo String}
  
 
    );
  ,
      ),
        ] ),,
                  )00,
   ght.w5Weight: Font     fontWei       ize: 12,
  ontS       f
       .white,or ?? Colors  color: col     
       tStyle(Tex    style:   
           text,    ext(
       T  ),
    th: 4x(widt SizedBo  cons),
        
          .white,r ?? Colorsolor: colo       c4,
     size: 1               icon,

         con(       Idren: [
       chil,
    xisSize.min: MainAzeSiAxis   main(
     d: Row     chil ),
 ),
     12.circular(Radiusius: BorderRader   bord,
     Opacity(0.2).withs.white) Color??: (color or       colcoration(
  BoxDeecoration:    d
  4),al:  verticzontal: 8,c(horits.symmetrit EdgeInsedding: cons
      patainer(on  return Cr}) {
   cololor?t, {Cotexcon, String nData ihip(IcoataCildMetadget _bu  
  Wid  );
  }

  
      ),
        ],          ),   ),
        ),
                 ],
                    ],
                             ),
              
    ],           
                  ),               n!,
   ta.locatio.metadaageItem!     _im                  _on,
     ocation  Icons.l                      
    p(tadataChibuildMe         _           [
       hildren:   c                     Row(
              
        : 4),(heightzedBox  const Si               ...[
     ll) tion != nucaadata.loageItem!.metf (_im      i            
     ],                 ),
                   ,
              ]     ,
                  )        
        }',ateTaken!).metadata.deItem!ate(_imag_formatD: ${    'Taken               ,
         a_altmer Icons.ca                           taChip(
ada _buildMet                    [
      en:     childr            ow(
                  R           ght: 4),
(heist SizedBox  con            
         ...[l)aken != nula.dateTm!.metadatf (_imageIte    i          ),
                     ,
         ]             ),
                           }',
  t)!.createdA_imageItemmatDate( ${_forreated:  'C                      
  _today,.calendar Icons                       Chip(
  data _buildMeta                   en: [
    ldr       chi              Row(
                ),
     height: 8st SizedBox(  con                  
  ),              ,
               ]               ),
                    mber,
   Colors.a   color:                
         te',     'Favori               
        ons.star,        Ic                    ip(
dataChuildMeta_b                        e)
  isFavoriteItem!.if (_imag                 ,
       : 8)x(widthzedBonst Si          co       ),
                             e),
  .fileSizgeItem!e(_imatFileSiz _forma                       rage,
  cons.sto I                        
 tadataChip(_buildMe                       dth: 8),
 dBox(wiizeonst S     c                   
  ),                     
 ,.height}'ata.metadItem!age× ${_imata.width} adm!.metgeIte{_ima '$                    
     ect_actual,oto_size_selns.ph       Ico                 taChip(
  adaMet _build                  
      [children:                    (
           Row     
      , 8)ht:igSizedBox(heconst                  
    ),                  ),
                   .bold,
    ightight: FontWe   fontWe                  e: 18,
     fontSiz                     ite,
 lors.whr: Co    colo            (
        xtStyle: const Te    style             me,
     tem!.na     _imageI                    Text(
                 [
ldren:     chi         in,
     ze.m MainAxisSiSize:   mainAxis        t,
       gnment.starssAxisAlinment: CroisAligssAx         cro       Column(
     child:        ),
                     
      ),          ],
                       nt,
transparers.    Colo              
    ty(0.8),withOpacirs.black.  Colo                  olors: [
             c    nter,
     topCe: Alignment.   end           ,
      tomCenterbotnment.Alig   begin:             nt(
     Gradie Linear   gradient:               oration(
n: BoxDeccoratio     de         ,
  l(16)Insets.alEdge: const     padding           ntainer(
 d: Co       chil 0,
          right:  ,
              left: 0       om: 0,
          bottd(
      ne Positio
           owMetadata)(_shf       i  
  om)(botta overlay   // Metadat
        
          ),          ),
       n(),
     mbNavigatioadcru const Brechild:          (0.7),
    cityithOpas.black.wcolor: Color         ner(
     Contaid: hil     c      ,
 right: 0       0,
      left:           : 0,
    top         ioned(
sitPo  )
        ion (topigat navBreadcrumb       //   
         
       ),),
          
       ,       )           ),
                 ),
         
     },                   );
                  ),
                        ],
                                ),
                       grey),
   lor: Colors.xtStyle(cole: Testy                    
          age',ad imo loe tnabl        'U               
       ext(   T              
           t: 16),zedBox(heigh     Si                        ),
                        grey,
   olors.  color: C                       
     4,e: 6iz   s                  
         ken_image,  Icons.bro                       
     n(  Ico                         [
 ldren:        chi              r,
     nment.centeainAxisAliggnment: MAxisAliin       ma              
     n(Columld: const        chi        
         l(32),.alsetsst EdgeIn con  padding:                 ner(
     rn Contai   retu                   Trace) {
stack, orerrntext, der: (corBuil      erro              n,
tait.con BoxFi  fit:               ,
   th)filePaimageItem!.File(_               ile(
     d: Image.fchil                  em!.id}',
imageIt${_mage_    tag: 'i             ero(
  H    child:         er(
    child: Cent             5.0,
 axScale:       m
       1,e: 0.     minScal         
ller,ntroformationCo: _transollertrtionConma    transfor          er(
View Interactive     child:l(
       .filsitioned          Poe view
 Main imag//   [
       children: 
        ack(ody: St
      b),      ],
    
            ),tions',
  More op: 'tipol          toons,
  ti_showImageOpssed: nPre       o    t),
 s.more_verst Icon(Iconconcon:   i          n(
onButto        Ic   ),
  o',
       'Toggle Inftooltip:               },
       );
              }ta;
   !_showMetadaMetadata = show           _) {
     setState((         
     ed: () {     onPresse),
       o_outlin Icons.inf : Icons.infota ?wMetada: Icon(_sho   icon         ton(
  IconBut      
          ),m',
   'Reset Zootooltip:         
   tZoom,ed: _resess       onPre,
     m_out_map)n(Icons.zoon: const Ico    ico        nButton(
        Ico  
  actions: [ite,
      Colors.whroundColor:        foregty(0.7),
 k.withOpaciblacrs.loolor: CoroundC       backg.name),
 mageItem!Text(_ititle: r(
        pBappBar: Ap     ack,
 blaolors.undColor: C   backgroffold(
   ca Sreturn  
     }
    );
          ),
  .'),
   ot be foundd ne coulted image requesd: Text('Th   chil      r(
  const Cente body:      nd')),
 mage Not Fou Text('Insttitle: coar: AppBar(appBd(
        n Scaffoltur re    
 ) { == nulleItemimagif (_     
  );
    }
   ),
    cator()ProgressIndiircular: CCenter(child  body: d(
      caffolrn const S      retuLoading) {
    if (_isxt) {
nteontext coildC build(BuWidget  
rride  
  @ove}
ntity();
  rix4.ideatue = Mler.valntrolnCosformatioan  _tr) {
   _resetZoom(  void
}
  }
  }
    
       }       );
       )),
   ash: $e'image to trg r movin('Erro: TextBar(content  Snack  
        (kBarSnacntext).shownger.of(coseesfoldM   Scaf  {
     f (mounted)     i (e) {
    tch
      } ca
        }ck Navigate bap(); //  context.po);
               )),
   o trash'oved t m('Imageontent: Textt SnackBar(c   cons        r(
 showSnackBatext).of(coner.Messengfold     Scafed) {
     nt   if (mou   
     .id);
     mageItem!(_itrashItemory.osittentRept con      awaie);
  ten: falstext, lis(conory>itontentRepos<Cofrovider.pository = PntRentenal co     fi
      try {ted) {
   & moun= true &confirmed =  if (;
    
  ),
    )   
        ], ),
       ,
      to Trash')t('Move: const Tex      child      xt, true),
ontepop(cgator.: () => Naviessed        onPr    Button(
   Text),
            ),
     ncel'('Cast Textld: con  chi    se),
      ntext, falcogator.pop(vi () => NanPressed: o        on(
   utt   TextB
       [tions:    ac  ),
   sh?'tra to mage move this int to sure you waou('Are y const Textntent:   co,
     Trash') to t('MoveTex const le: tit     
  alog(> AlertDi) = (contextilder:t,
      buexontext: c
      contlog<bool>(t showDiaed = awairmnal confi    
    fi;
null) returneItem == f (_imag{
    inc ) asyTrash(_moveTore<void>   Futu 

  }
     }    }
   );
  )),
     mage: $e'xporting ixt('Error econtent: TenackBar(  S       
 SnackBar().showxt.of(conteerssengcaffoldMe{
        Smounted)     if () {
   (etch    } ca}
;
             )
 tPath')),or $exported to:e expt('Imagtent: TexackBar(con      Sn(
    wSnackBarntext).shor.of(cofoldMessengeScaf     {
    && mounted)ath != null portP     if (ex;
      
 d)tem!.ieIagtem(_importIry.exntReposito conteawaith =  exportPatinal f);
     n: falsentext, listesitory>(cotentRepoder.of<Con = ProvitoryntentReposi   final co   

    try {
    return;m == null)  (_imageItec {
    ifsynortImage() aexpture<void> _
  Fu);
  }
  n')),
    y coming soonalittiofunc'Share : Text(ntent SnackBar(co   constkBar(
   wSnact).shof(contexssenger.oScaffoldMeackage
    e_plus p use shar typicallyould wis
    // Thality functiontual sharingplement ac // TODO: Im      
return;
 null) ageItem == if (_imc {
    ) asynmage(d> _shareI Future<voi  }
  
 spose());
troller.di> nameConthen((_) =,
    ).
      )     ],       ),
   ,
   t('Rename')nst Tex child: co    
              },
         }             }
                   }
       
      );            )),
       ge: $e'naming imaor rerr Text('EBar(content:ck Sna               r(
      howSnackBaxt).sconte.of(ldMessenger   Scaffo                 ed) {
ount(m       if            e) {
} catch (                       }
 
               );              ),
 renamed')age t('Imexntent: TBar(coacknst Sn co                   kBar(
  Snact).showf(contexsenger.oaffoldMes     Sc          ) {
     tedoun    if (m             
                   );
p(contextpoator.vigNa                          
 ;
              })            e;
 pdatedImageItem = u_imag                 ) {
   etState((      s                
          
    ge);updatedImatItem(eConteny.updatsitorentRepoawait cont                     
             );
                
    ime.now(),dAt: DateTdifie     mo             text,
  ntroller. nameCoame:  n                
  (yWithItem!.cop = _imageImageupdatedfinal             e);
      listen: falst, ory>(contexitepostR.of<ContenviderPro = itorycontentReposfinal         
          y {    tr             {
tem != null)_imageI && tyext.isNotEmpler.trolContmeif (na              c {
yn () as  onPressed:
          on(xtButt       Te  ),
           ,
Cancel')st Text('con:        child,
     p(context)or.poNavigatssed: () =>   onPre         ton(
 tBut    Tex      ctions: [
 a,
       
        )     ),e',
     namer new ext: 'Ent  hintT          Name',
 xt: 'ImagelabelTe         ion(
   tDecoratnpuconst Idecoration:      rue,
     focus: t       auto
   ntroller,: nameCocontroller          TextField(
content: ,
        e Image')Renam('t Textitle: cons(
        tertDialogAl) => r: (contextlde     buixt,
 ntext: co     conte
 g(  showDialo
    
  );   ,
 ''name ?? ageItem?.   text: _im(
   olleringContrtEdit = Texontroller nameClertingControltEdi Tex
    finalialog() {showRenameD
  void _ }
  }
        }
       );
  )),
  e: $e'riting favodatError upt: Text('contenar(ackB       Sn(
   ckBarshowSnatext)..of(conoldMessengerffca S      d) {
 (mounte     if tch (e) {
     } ca}
);
          ),
         '),
     m favoritesemoved froorites' : 'Rdded to fave ? 'Aritavoem!.isFageIt Text(_imtent:  con         r(
 SnackBa          ckBar(
owSnaontext).sher.of(cssengldMeffo
        Scated) {oun    if (m   
     );
  }
    avorite);!.isF_imageItemFavorite: !.copyWith(isageItem!m = _imeIteag _im) {
         setState(( 
    
     Item!.id);ge_imaFavorite(ory.togglentRepositwait conte;
      afalse): ext, listenitory>(contntReposder.of<ConteProviepository =  contentR     final