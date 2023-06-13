% version 2.5 2019/12/20 Bugfixes: Switched to pdf/a a-2b, list of acronyms with
%                                  nomencl, fix tests, switch to a custom Dockerfile,
%                                  add support+example demonstrating minted
% version 2.4 2019/05/28 Bugfixes: Fixed app. page count for documents with multipage
%                                  floating content in appendices, adjustments to
%                                  options and font handling, documentation, options
%                                  for handling long urls in the bibliography,
%                                  removed unnecessary deps titlecaps & sverb
% version 2.3 2019/05/02 Bugfixes: PDF/A-1b support (via pdfx), moved chead to cfoot,
%                                  updated UTU logos
% version 2.2 2018/10/06 Bugfixes: Got rid of startappendices and startpages.
%                                  various fixes. cleanups
% version 2.1 2018/10/02 Bugfixes: removed redundant tutkielma.tex, fixed issues with
%                                  appendices, small caps, added an option to enable
%                                  the truetype times new roman font
% version 2.0 2018/08/29 new version using document classes, xelatex, biblatex, and
%                        additional TeX scripting. Jari-Matti Mäkelä (jmjm@iki.fi)
% version 1.3+ 2017/10/01 - 2016/9/22 additions marked "JH:", modified for use in
%                                     tex.soft.utu.fi, Johannes Holvitie (jjholv@utu.fi)
% version 1.3 2015/09/05 Sami Nuuttila (samnuutt@utu.fi)

% ------------------------------
% How to use? Store the file in
% 1) Windows XP C:\Documents and Settings\<user name>\texmf\tex\latex\local\
% 2) Windows Vista/7 C:\Users\<user name>\texmf\tex\latex\local\
% 3) Linux ~/texmf/tex/latex/local/
% 4) Mac OS X /Users/<user name>/Library/texmf/tex/latex/local/
% 5) Sharelatex: just copy this file to the project folder
% 6) or in the same directory as the document
% ------------------------------

\NeedsTeXFormat{LaTeX2e}[2015/01/01]
\ProvidesClass{utuftthesis}[2020/06/18 UTU FT dept BSc/MSc thesis]

%% package requirements for this template
\RequirePackage{kvoptions}                    % keyval-options, required by this class definition
\RequirePackage{adjustbox}                    % front page box on the right
\RequirePackage{etoolbox}                     % misc. tools
\RequirePackage{ifthen}                       % mainly: \langchoose and \switch (\ifstrequal doesn't work here?)
\RequirePackage{ifxetex}                      % for xelatex/pdflatex font selection
\RequirePackage{fancyhdr}                     % customized headers/footers
\RequirePackage{xstring}                      % string comparison
\RequirePackage[lastpage,totpages,user]{zref} % page counting logic

%% Custom package options
%\DeclareStringOption[00]{year}
\DeclareStringOption[draft]{version}         % draft/final version
\DeclareStringOption[a4paper]{paper}         % @see ctan/macros/latex/base/classes, 3.1 Setting Paper Size
\DeclareStringOption[finnish]{language}      % document's main language
\DeclareStringOption[ieee]{bibstyle}         % document's bibliography style
\DeclareStringOption[-1]{pagecountdelta}     % workaround for bugs in the app page count
\DeclareStringOption[a-2b,mathxmp]{pdfaconformance}  % PDF-A conformance level (a-1b, a-2b, a-2u, a-3b, a-3u, or 'none')
\DeclareStringOption[split]{biburlbreak}     % how to handle long urls in bibliography ('ragged', 'split', or 'none')
\DeclareStringOption[times]{mainfont}        % pdftex: main font package (lmodern, fourier, ...), special value: 'times', 'none'
                                             % xetex: main font name (Arial, Comic Sans, ...), special value: 'times' enables Times New Roman, 'none'
\DeclareBoolOption[true]{hidechapters}       % hide the verbose chapter title text
\DeclareBoolOption[true]{hidelinks}          % hide the underlining of links (PDF-A & hyperref)
\DeclareBoolOption[false]{countbibpages}     % page count = content | content + bibliography pages?
\DeclareBoolOption[false]{sharelatex}        % assume compilation inside sharelatex
\DeclareBoolOption[false]{minted}            % use minted instead of listings (must enable -shell-escape!)
\DeclareBoolOption[true]{emptyfirstpages}    % hide the header/footer of the first page of each chapter
\DeclareBoolOption[true]{turnitinchecked}    % turnitin text
\DeclareBoolOption[false]{turnitinnewpage}   % turnitin text on a new page
\DeclareBoolOption[false]{hidetocpagenum}    % hide the roman page numbers in toc / lists


%% Process given options
\ProcessKeyvalOptions*

%% Load base
\LoadClass[\utuftthesis@paper,12pt]{report}

%% !! Update this only if the document's main language is not finnish or english !!
%% The template supports one of three options
%%  * \n@tivelang + english
%%  * just \n@tivelang
%%  * just english
\def\n@tivelang{}

%% macros for conditional language blocks
\newcommand{\l@nguage}{\utuftthesis@language}
\newcommand{\langchoose}[3]{\ifthenelse{\equal{#1}{\n@tivelang}}{#2}{#3}}
\newcommand{\langfin}[2]{\langchoose{\l@nguage}{#1}{#2}}

%% switch-case used to select the thesis type
\newbool{default}
\newcommand{\case}{}
\newcommand{\default}{}
\newenvironment{switch}[1]{%
    \booltrue{default}
    \renewcommand{\case}[2]{\ifthenelse{\equal{#1}{##1}}{%
        \boolfalse{default}##2}{}}%
    \renewcommand{\default}[1]{\ifbool{default}{##1}{}}
}{}

%% Set up encoding/font/hyphenation stuff
%% Note: this basic setup is mainly meant for latex newbies unaware of
%% the fine art of typography. The basic font configuration can be set
%% up with the document parameters 'realtimesnewroman' & 'mainfont'
%% Configurations:
%%  * realtimesnewroman=F on luatex/xetex: uses the standard LaTeX fonts
%%  * realtimesnewroman=F on pdftex: sets up the font package 'mainfont'
%%  * realtimesnewroman=T on pdftex: uses the default Times font family
%%    (may look similar to MS Office)
%%  * realtimesnewroman=T on luatex/xetex: uses Times New Roman or fails (must be found)
%%    (may look similar to MS Office)
%%  * advanced:
%%    set up the font settings in the document header
%%    some suggestions: opentype, xetex, microtype, ligatures,
%%    commercial fonts, mixing & matching different fonts
%%    @see https://en.wikibooks.org/wiki/LaTeX/Fonts#Using_alternative_fonts
%%    @see http://www.khirevich.com/latex/microtype/
\ifxetex
  \RequirePackage{fontspec}

  % https://bitbucket.org/martin_scharrer/filehook/issues/1/latex-will-change-definition-of
  \RequirePackage{scrlfile}

  \RequirePackage{polyglossia}
  % see bug https://github.com/reutenauer/polyglossia/issues/331
  %\setmainlanguage{\utuftthesis@language}
  \begingroup\edef\x{\endgroup\noexpand\setdefaultlanguage{\utuftthesis@language}}\x%
  \langfin{\setotherlanguage{english}}
  
  \ifdefstring{\utuftthesis@mainfont}{times}{
    \ifutuftthesis@sharelatex
      % ShareLaTeX doesn't ship with (C) Microsoft corefonts,
      % need to provide the font files locally inside the project
      \setmainfont[BoldFont=timesbd.ttf,ItalicFont=timesi.ttf,BoldItalicFont=timesbi.ttf]{times.ttf}
    \else
      \setmainfont{Times New Roman}
    \fi
  }{
    \ifdefstring{\utuftthesis@mainfont}{none}{
    }{
      \setmainfont{\utuftthesis@mainfont}
    }
  }
\else
  % JH: modified latin to UTF-8 encoding cues to make Scandinavian characters work
  \RequirePackage[T1]{fontenc}
  \RequirePackage[utf8]{inputenc}

  % load babel-package for automatic hyphenation
  \ifdefstring{\utuftthesis@language}{english}{
    \RequirePackage[english, \n@tivelang]{babel}
  }{
    \RequirePackage[english, \l@nguage]{babel}
  }
  
  \ifdefstring{\utuftthesis@mainfont}{none}{
  }{
    % Note: the system picks the configured default Times font family font
    % On Linux/Mac/ShareLaTeX, could be Nimbus or other font, not Times New Roman due to license issues
    \ifdefstring{\utuftthesis@mainfont}{times}{
      % roman font: times
      \renewcommand{\rmdefault}{ptm}
    }{
      \RequirePackage{\utuftthesis@mainfont}
    }
    
    % sans-serif: helvetica
    \renewcommand{\sfdefault}{phv}
    
    % monospace font: courier
    \renewcommand{\ttdefault}{pcr}
  }
\fi

\ifdefstring{\utuftthesis@version}{draft}{
  \newcommand{\version}{[draft]}

}{
  \newcommand{\version}{}
  
  \ifdefstring{\utuftthesis@pdfaconformance}{none}{
  }{
    %% @see http://ftp.acc.umu.se/mirror/CTAN/macros/latex/contrib/pdfx/pdfx.pdf
    %% @see https://en.wikipedia.org/wiki/PDF/A#Conformance_levels_and_versions
    \RequirePackage{colorprofiles}
    \RequirePackage[\utuftthesis@pdfaconformance]{pdfx}
    %% fix a temporary bug in texlive 2021
    \catcode30=12
    
    %% hides the underlining of links with red (by hyperref)
    %% @see http://mirrors.ctan.org/macros/latex/contrib/hyperref/doc/manual.pdf
    %% note: pdfx implicitly imports hyperref
    \ifutuftthesis@hidelinks
      \hypersetup{hidelinks}
    \fi
  }
}

%% not used by the class, but usually needed
%% if you encounter package clashes, start by disabling these
%% @see https://tex.stackexchange.com/a/26592
%% @see https://tex.stackexchange.com/q/553
%% @see https://tex.stackexchange.com/a/26200
%% @see https://www.ctan.org/topic/obsolete
\RequirePackage{verbatim}               % LyX generated \begin{comment}\end{comment}
\RequirePackage{graphicx}               % \includegraphics{file}, works without file extensions
\RequirePackage{amssymb,amsthm,amsmath} % ams-packages for maths
%\RequirePackage{filecontents}           % to output the pdfx metadata file
\RequirePackage{nomencl}                % acronyms, https://tex.stackexchange.com/questions/154060/nomenclature-acronym-or-glossary
                                        % https://www.overleaf.com/learn/latex/Nomenclatures

\ifutuftthesis@minted
\RequirePackage{minted}                 % handle inclusion of source code. Requires Python & pygments.
\else
\RequirePackage{listings}               % handle inclusion of source code.
                                        % note: does not support utf-8 properly!
\newenvironment{minted}{\verbatim}{\endverbatim}
\newcommand{\listingscaption}{\sourcecode}
\fi

%% some more suggestions
%\RequirePackage[l2tabu, orthodox]{nag} % checks whether outdated latex features are being used
%\RequirePackage[all,warning]{onlyamsmath}
%\RequirePackage{titlecaps}             % capitalized words in titles
%\RequirePackage{microtype}
%\RequirePackage{amssymb}
%\RequirePackage{fixmath}
%\RequirePackage[euro]{isonums}
%\RequirePackage[amsmath,thmmarks,hyperref]{ntheorem}

% bold acronyms in the list of acronyms
\renewcommand{\nomlabel}[1]{{\textbf{#1}}}
\makenomenclature
\newcommand{\listofacronyms}{\printnomenclature}

%% packages that depend on language packages / definitions

%% @see https://tex.stackexchange.com/a/134281
\ifdefstring{\utuftthesis@biburlbreak}{break}{
  \setcounter{biburllcpenalty}{7000}
  \setcounter{biburlucpenalty}{8000}
}{}

%% bibliography, new engine
\ifdefstring{\utuftthesis@biburlbreak}{ragged}{
  \RequirePackage[style=\utuftthesis@bibstyle,backend=biber,block=ragged]{biblatex}
}
{
  \RequirePackage[style=\utuftthesis@bibstyle,backend=biber]{biblatex} 
}

\RequirePackage{fvextra}                % minted
\RequirePackage{csquotes}               % quotations

\langfin{
  \RequirePackage[fi,en-US]{datetime2}        % month names
}{
  \RequirePackage[en-US,fi]{datetime2}        % month names
}


%% !! Update these only if the document's main language is not finnish or english !!
\newcommand{\ye@r}{\the\year}
\newcommand{\m@nth}{\the\month}
\newcommand{\p@blab}{Labra}
\newcommand{\p@blaben}{Laboratory}
\newcommand{\s@pervisors}{none}
\newcommand{\k@ywords}{not set}
\newcommand{\k@ywordstwo}{not set}
\newcommand\keywords[1]{\renewcommand\k@ywords{#1}}
\newcommand\keywordstwo[1]{\renewcommand\k@ywordstwo{#1}}
\newcommand\keywordsen[1]{\renewcommand\k@ywordstwo{#1}}
\newcommand\pubyear[1]{\renewcommand\ye@r{#1}}
\newcommand\pubmonth[1]{\renewcommand\m@nth{#1}}
\newcommand\publab[1]{\renewcommand\p@blab{#1}}
\newcommand\publaben[1]{\renewcommand\p@blaben{#1}}
\newcommand\pubtype[1]{\newcommand\p@btype{#1}}
\newcommand\supervisors[1]{\renewcommand\s@pervisors{#1}}
\newcommand{\department}[1]{\langchoose{#1}{Tietotekniikan laitos}{Department of Computing}}
\newcommand{\university}[1]{\langchoose{#1}{Turun yliopisto}{University of Turku}}
\newcommand{\University}[1]{\langchoose{#1}{\MakeUppercase{Turun yliopisto}}{\MakeUppercase{University of Turku}}}
\newcommand{\labname}[1]{\langchoose{#1}{\p@blab}{\p@blaben}}
\newcommand{\pagesname}[1]{\langchoose{#1}{s.}{p.}}
\newcommand{\apppagesname}[1]{\langchoose{#1}{liites.}{app. p.}}
\newcommand{\kwlabel}[1]{\langchoose{#1}{Asiasanat}{Keywords}}
\newcommand{\supervisorstext}{\langfin{Tarkastajat}{Supervisors}}
\newcommand{\turnitin}{\langfin{Turun yliopiston laatujärjestelmän mukaisesti tämän julkaisun alkuperäisyys on tarkastettu Turnitin OriginalityCheck-järjestelmällä.}
{The originality of this thesis has been checked in accordance with the University of Turku quality assurance system using the Turnitin OriginalityCheck service.}}

%% needs to be implemented like this due to the initialization order
\langfin{
  \newcommand{\refs}{Lähdeluettelo}
  \newcommand{\appname}{Liitteet}
  \renewcommand{\nomname}{Termistö}
  \newcommand{\sourcecode}{Ohjelmalistaus}
}{
  \newcommand{\refs}{References}
  \newcommand{\appname}{Appendices}
  \renewcommand{\nomname}{List of acronyms}
  \newcommand{\sourcecode}{Listing}
}

%% magic thesis types. more can be added
%% non-magic types are passed through, which is sufficient for documents
%% with only a single language
\newcommand*{\thesistype}[1]{
  \begin{switch}{\p@btype}
    \case{tkk}{\langchoose{#1}{TkK-tutkielma}{Bachelor's Thesis}}%
    \case{luk}{\langchoose{#1}{LuK-tutkielma}{Bachelor's Thesis}}%
    \case{gradu}{\langchoose{#1}{Pro gradu -tutkielma}{Master of Science Thesis}}%
    \case{di}{\langchoose{#1}{Diplomityö}{Master of Science (Tech) Thesis}}%
    \default{\p@btype}%
  \end{switch}}

%% constructs a month name for datetime2
%% @see TeX Book, Chapter 7: How TeX Reads What You Type (p 40)
%% @see http://ftp.acc.umu.se/mirror/CTAN/macros/latex/contrib/datetime2/datetime2.pdf
%% note: for some languages (en), need to provide a macro such as
%%   DTM<language>Monthname -> DTM<language>monthname
\newcommand{\DTMenglishMonthname}[1]{\DTMenglishmonthname{#1}}
\newcommand{\monthname}[1]{\csname DTM#1Monthname\endcsname}

%% -- end of localization --


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% setup document appearance
%

% fix page size
%
%  - page width: 
%     1inch             +
%      \hoffset         +
%      \oddsidemargin   +
%      \textwidth       +
%      \marginsep       +
%      \marginparwidth
%
%  - page height: 
%     1inch             +
%      \voffset         +
%      \topmargin       +
%      \headheight      +
%      \headsep         +
%      \textheight      +
%      \footnotesep     +
%      \footheigth 
%
%  - 1 pt == 1/72 inch == 0.35 mm
%
% page width... left margin 4cm, right 2cm
%
\setlength{\hoffset}{0mm}
\setlength{\marginparsep}{0mm}
\setlength{\marginparwidth}{0mm}
\setlength{\textwidth}{\paperwidth}
\addtolength\textwidth{-60 mm}
\setlength{\oddsidemargin}{-1 in}
\addtolength\oddsidemargin{40 mm}

% page height... textheight starts at ~4cm from top, 
% i.e. 1 in + 12 pt + 24 pt = 1.5 in 
%
\setlength{\voffset}{0 mm}
\setlength{\topmargin}{0 mm}
\setlength{\headheight}{14.5 pt}
\setlength{\headsep}{24 pt}
\setlength{\textheight}{230mm}
\setlength{\footnotesep}{12 pt}

 
% setup linespacings to suit to the (stupid) requirement of double spacing
%
% - fake 1.5 linespacing
%    \renewcommand{\baselinestretch}{1.241}
%
% - fake 2 linespacing
%
\renewcommand{\baselinestretch}{1.655}
  
%% Modify the \printbibliography command
\defbibheading{bibliography}[\refs]{
  \zlabel{endofmaincontent}
  \chapter*{#1}
  \markboth{\MakeUppercase{#1}}{}
  \addcontentsline{toc}{chapter}{#1}
}

%% backup the old \printbibliography
\let\oldprintbibliography\printbibliography

\renewcommand{\printbibliography}{
  \oldprintbibliography
  \zlabel{endofbibliography}
\langfin{
  \expandafter\selectlanguage\expandafter{\n@tivelang}
}{
  \selectlanguage{english}
}
}

%% Macro for hiding the chapter texts
\ifutuftthesis@hidechapters
  \renewcommand{\@chapapp}{\relax}
  \renewcommand{\@makechapterhead}[1]{%
    \vspace*{50\p@}%
    {\parindent \z@ \raggedright \normalfont
      \ifnum \c@secnumdepth >\m@ne
          \huge\bfseries \@chapapp\space \thechapter\space\space
      \fi
      \interlinepenalty\@M
      \Huge \bfseries #1\par\nobreak
      \vskip 40\p@
    }}
\fi

%% entry environment
\newenvironment{entry}[1]{\begin{list}{}{%
    \renewcommand{\makelabel}[1]{\textrm{##1:}\hfil}%
    \settowidth{\labelwidth}{\textrm{#1:}}%
    \setlength{\leftmargin}{\labelwidth}%
    \addtolength{\leftmargin}{\labelsep}}}
{\end{list}}

%% the first abstract
\langfin{
  \renewenvironment{abstract}{\expandafter\@bstracth\expandafter{\n@tivelang}{1}}{\expandafter\@bstractt\expandafter{\n@tivelang}{\k@ywords}}

  %% the second abstract environment in english
  %% can be omitted if the document uses a single language
  \newenvironment{abstracten}{\@bstracth{english}{2}}{\@bstractt{english}{\k@ywordstwo}}
  \newenvironment{abstracttwo}{\@bstracth{english}{2}}{\@bstractt{english}{\k@ywordstwo}}
}{
  \renewenvironment{abstract}{\@bstracth{english}{1}}{\@bstractt{english}{\k@ywords}}

  %% the second abstract environment in native language
  %% can be omitted if the document uses a single language
  \newenvironment{abstracten}{\expandafter\@bstracth\expandafter{\n@tivelang}{1}}{\expandafter\@bstractt\expandafter{\n@tivelang}{\k@ywordstwo}}
  \newenvironment{abstracttwo}{\expandafter\@bstracth\expandafter{\n@tivelang}{1}}{\expandafter\@bstractt\expandafter{\n@tivelang}{\k@ywordstwo}}
}

\newcommand\lastapppage{\zref@extractdefault{appendices}{abspage}{999}}
\newcommand\apppagecount{\number\numexpr \ztotpages - \lastapppage + 1\relax}
\newcommand{\pagecounttext}[1]{%
  \ifutuftthesis@countbibpages
    \zref@extractdefault{endofbibliography}{page}{\zref@extractdefault{LastPage}{page}{0}} \pagesname{#1}%
  \else
    \zref@extractdefault{endofmaincontent}{page}{\zref@extractdefault{LastPage}{page}{0}} \pagesname{#1}%
  \fi
  \IfStrEq*{\lastapppage}{999}{}{, \apppagecount\ \apppagesname{#1}}
}

%% title page, reuses the standard \maketitle
\renewcommand*{\maketitle}{%
  %\clearpage 
  \begin{titlepage}
  \setcounter{page}{0}
  \pagenumbering{alph}
  \thispagestyle{empty}
  \vspace*{\stretch{1}}
  \vspace{3mm}
  \noindent 
  \rule{\linewidth}{1 mm}
  \renewcommand{\baselinestretch}{1.05}\normalsize
  \begin{flushright}
  \Huge{\@title}
  \end{flushright}
  \rule{\linewidth}{1 mm}
  \vspace*{\stretch{4}}

  \renewcommand{\baselinestretch}{1}\normalsize
  \begin{adjustbox}{minipage=65mm,right}
  \thesistype{\l@nguage}\\
  \university{\l@nguage}\\
  \department{\l@nguage}\\
  \labname{\l@nguage}\\
  \ye@r\\
  \@author
  \ifdefstring{\s@pervisors}{none}{}{\\
    \\
    \supervisorstext:
    \expandafter\forcsvlist\expandafter\\\expandafter{\s@pervisors}
  }
  \end{adjustbox}
  \vspace*{\stretch{1}}%
  \ifutuftthesis@turnitinchecked
    \ifutuftthesis@turnitinnewpage
      \newpage
      \thispagestyle{empty}
      \vspace*{\stretch{1}}
    \else
      \\
    \fi
    \scriptsize \noindent{\turnitin}
  \fi
  
  \end{titlepage}
  \renewcommand{\baselinestretch}{1.655}\normalsize
  \clearpage
}

%% top part of the abstract page (since we use environments)
\newcommand{\@bstracth}[2]{%
  \selectlanguage{#1}
  \setlength{\headheight}{0 pt}
  \setlength{\headsep}{0 pt}
  \addtolength\topmargin{-0.54 cm}
  \renewcommand{\baselinestretch}{1}\normalsize
  \clearpage
  \pagenumbering{alph}
  \addtocounter{page}{#2}
  \thispagestyle{empty}
  \pagestyle{empty}
  \noindent
  \University{#1}\\
  \department{#1}
  \begin{entry}{}
  \item[\textsc{\@author}] \@title
  \end{entry}
  \thesistype{#1}, %
  \pagecounttext{#1} \\
  \labname{#1} \\
  \monthname{#1}{\m@nth} \ye@r\\
  \rule{\linewidth}{1 pt}%
  \setlength{\parindent}{0em}%
  \\
}

%% bottom part of the abstract page
\newcommand{\@bstractt}[2]{%
  \selectlanguage{#1}%
  \bigskip%
  \begin{entry}{}
    \item[\kwlabel{#1}] #2
  \end{entry}
  \setlength{\parindent}{1.5em}%
  \clearpage
  \setlength{\headheight}{12 pt}%
  \setlength{\headsep}{24 pt}%
  \setlength{\topmargin}{0 mm}%
  \renewcommand{\baselinestretch}{1.655}%
  \normalsize%
  % roman numbering for table of contents etc.
  \pagenumbering{roman}
}

%% define \figcaption and \tblcaption for use with non-floating figures and tables
\newcommand\figcaption{\def\@captype{figure}\caption}
\newcommand\tblcaption{\def\@captype{table}\caption}

%% compatible with old versions that required using \startpages
%% now optional
\newcommand{\startpages}{\initdocstyle}

\newcommand{\inittocstyle}{%
  \ifutuftthesis@hidetocpagenum
    \fancypagestyle{plain}{\fancyhf{}\renewcommand{\headrulewidth}{0 pt}}
  \fi
}

%% initializes the settings for main document content
\newcommand{\initdocstyle}{%
  \renewcommand{\startpages}{}
\langfin{
  \expandafter\selectlanguage\expandafter{\n@tivelang}
}{
  \selectlanguage{english}
}
  \clearpage
  % clear 1st page headers/footers per request
  \ifutuftthesis@emptyfirstpages
    \fancypagestyle{plain}{\fancyhf{}\renewcommand{\headrulewidth}{0 pt}}
  \fi
  \pagenumbering{arabic}
  \setcounter{page}{1}
  \renewcommand{\baselinestretch}{1.655}
  \pagestyle{fancy}
  \renewcommand{\chaptermark}[1]{\markboth{\MakeUppercase{\chaptername\ \thechapter.\ ##1}}{}}
  \lhead{\leftmark}
  \chead{}
  \rhead{\thepage}
  \fancyfoot{}
  \cfoot{\version}
}       

%% postpone the doc style through these sections
\pretocmd{\tableofcontents}{\renewcommand{\startpages}{}\inittocstyle}{}{}
\apptocmd{\tableofcontents}{\renewcommand{\startpages}{\initdocstyle}}{}{}
\pretocmd{\listoffigures}{\renewcommand{\startpages}{}}{}{}
\apptocmd{\listoffigures}{\renewcommand{\startpages}{\initdocstyle}}{}{}
\pretocmd{\listoftables}{\renewcommand{\startpages}{}}{}{}
\apptocmd{\listoftables}{\renewcommand{\startpages}{\initdocstyle}}{}{}
\pretocmd{\listofacronyms}{\renewcommand{\startpages}{}}{}{}
\apptocmd{\listofacronyms}{\renewcommand{\startpages}{\initdocstyle}}{}{}

%% finally initialize the main document style
\pretocmd{\chapter}{\startpages}{}{}

%% compatible with old versions that required using \appendices
%% now optional
\newcommand{\appendices}{\startappendices}

%% initializes the settings for appendices
\newcommand{\startappendices}{%
  \renewcommand{\appendices}{}
  \clearpage
  \appendix
  \zlabel{appendices}
  \addtocontents{toc}{\protect\contentsline{chapter}{\appname}{}\relax}
  \renewcommand{\chaptermark}[1]{\markboth{\MakeUppercase{\appendixname\ \thechapter.\ ##1}}{}}
  \rhead{\thechapter-\arabic{page}}
  \renewcommand\thepage{\thechapter-\arabic{page}}
}

%% use in place of \chapter
\newcommand{\appchapter}[1]{%
  \appendices
  \clearpage
  \setcounter{page}{1}
  \chapter{#1}
}

%% a workaround for documents having lots of floating content that is
%% not included in \totalcount@page. This hook increases the page counter
%% by one, but is compensated by \utuftthesis@pagecountdelta.
%% @see https://tex.stackexchange.com/questions/736/pagebreak-vs-newpage
\AtEndDocument{\newpage}
