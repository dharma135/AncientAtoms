      subroutine output(iat,natx,ntitx,ndopx,ngeomx,maxln,nlogx,
     $           nexafs, ifeff,
     $           iabs,itot,ntit,idop,ngeom,imult,
     $           title,tag,edge,core,dopant,outfil,elemnt,
     $           vrsion,percnt,exafs,atlis,
     $           logic,vaxflg,
     $           tglist,xwrite,ywrite,zwrite,rwrite,index,npot)
c=====================================================================
c  atom module 7:  write feff.inp, geom.dat
c=====================================================================
c  this module consists of the following subroutines and functions:
c     output card feffpr geout
c  this module calls function ref
c=====================================================================
      implicit real(a-h,o-z)
      implicit integer(i-n)
c      implicit double precision (a-h,o-z)
c----------------------------------------------------------------------
c  organize the results of the cluster expansion in a scratch file
c  for use in feffpr, then call feffpr.
c----------------------------------------------------------------------
c integers:
c    iat,natx,ntitx,ndopx,ngeomx,maxl,nmlogx
c         :  parameters set in calling program
c    ifeff:  unit number of feff.inp
c    iabs:   index of absorbing atom in arrays dimmensioned iat
c    itot:   number of atoms in cluster
c    ntit:   number of title lines
c    idop:   (iat) number of species at each site, 1=no dopants, 2+=dopants
c    ngeom:  (ngeomx) one bounce flags for geom.dat
c
c characters
c    title*72:  (ntitx) title lines
c    tag*10:    (iat) site tag for each unique crystallographic site
c    edge*2:    absorbing edge, K, L3
c    core*10:   tag of absorbing atom
c    dopant*2:  (iat,ndopx) matrix with all host and dopant atomic symbols
c    outfil*72: output file name
c    vrsion*5:  version number as a character string
c
c reals:
c    percnt:  (iat,ndopx) occupancies of species and dopants at each site
c    amu:     total absorption above edge in cm^-1
c    delmu:   change in absorption at edge in cm^-1
c    spgrav:  specific gravity of crystal
c    sigmm:   McMaster correction sigma^2
c    qrtmm:   McMaster correction sigma^4
c    ampslf:  self absorption correction amplitude factor
c    sigslf:  self absorption correction sigma^2
c    qrtslf:  self absorption correction sigma^4
c    sigi0:   i0 correction sigma^2
c    qrti0:   i0 correction sigma^4
c    atlis:   (natx, 8) array of all atoms in cluster
c              1-3 -> pos. in cell     4 -> dist to origin
c                5 -> atom type      6-8 -> cartesian coords
c
c logicals:
c    logic:   array of flags, see arrays.map
c    vaxflg:  set to true if compiled on a Vax
c
c workspace, all of dimension maxln
c    tglist (character)
c    xwrite, ywrite, zwrite, rwrite  (real)
c    index, npot (integer)
c----------------------------------------------------------------------
c      parameter (iat=50, natx=800, ntitx=9, ndopx=4, ngeomx=800)
      parameter (iuscr=3, iug=4)

      character*2  edge,dopant(iat,ndopx),dp,test,elemnt(iat)
      character*9  fname,vrsion*5
      character*10 tag(iat),core,tagcen
      character*72 title(ntitx),outfil,outf
      dimension    atlis(natx,8), idop(iat), percnt(iat,ndopx),
     $             ngeom(ngeomx), exafs(nexafs), imult(iat)
      logical      logic(nlogx), vaxflg
      character*10 tglist(maxln)
      dimension    xwrite(maxln), ywrite(maxln), zwrite(maxln),
     $             rwrite(maxln), index(maxln), npot(maxln)

 4000 format(a)
 4100 format(1x,a2,3(3x,f8.4),3x,a10,3x,f8.4)
 4200 format(1x,'# This atoms.lis file generated by ATOMS, version ',
     $       a4,/)

      test = 'ab'

c  get tag for core atom
      do 5 i=1,idop(iabs)
        dp = dopant(iabs,i)
        call case(test,dp)
        if (core(1:2).eq.dp) then
            tagcen = tag(iabs)
c             tagcen = dopant(iabs,i)
c             call fixsym(tagcen(1:2))
        endif
 5    continue

c !!!!! don't change the status of this file !!!!!

      outf=outfil
      call case(test,outf)
c     --- write a feff.inp file (and maybe a geom.dat file) ...
      if (outf.ne.'list') then
          if (logic(6)) then
              if (logic(26)) call messag('  calling geout...')
              call geout(ngeomx, ntitx, natx,
     $            iug, itot, ntit, ngeom, maxln,
     $            atlis, vrsion, title, vaxflg)
          endif

          if (logic(26)) call messag('  calling feffpr...')
          call feffpr(iat,natx,ntitx,ndopx,maxln,nexafs,nlogx,
     $            ifeff,iuscr,itot,ntit,imult,
     $            edge,core,tag,title,tagcen,exafs,atlis,
     $            logic, idop,dopant,percnt,elemnt,
     $            tglist,xwrite,ywrite,zwrite,rwrite,index,npot)
          close(ifeff)
c     --- or write a simple list of atoms
      else
          if (logic(26))
     $           call messag('  opening and writing atoms.lis...')
          fname = 'atoms.lis'
          call lower(fname)
          open (unit=iuscr, file=fname, status='unknown')

c  make atom list
c  the list file is six columns: sym x y z tag r
          do 15 i=1,ntit
            write(iuscr,4000)title(i)
 15       continue
          write(iuscr,4100) core(1:2),  atlis(1,6), atlis(1,7),
     $                atlis(1,8), tagcen,     atlis(1,4)

          do 20 j=2,itot
            kat = nint(atlis(j,5))
            write(iuscr,4100) dopant(kat,1), atlis(j,6), atlis(j,7),
     $                  atlis(j,8),    tag(kat),   atlis(j,4)
 20       continue
          write(iuscr,4200)vrsion
          close(unit=iuscr, status='keep')
          outfil = fname
      endif

      return
c end module output
      end
