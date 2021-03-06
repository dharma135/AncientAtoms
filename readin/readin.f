      subroutine readin(iat,natx,ntitx,ndopx,ngeomx,neptx,nlogx,ifeff,
     $      ntit,iatom,ibasis,iabs,isystm,iperm,
     $      ipt,iptful,idop,ngeom,iedge,nepts,nsites,nrefl,nnoan,
     $      vrsion,spcgrp,inpgrp,title,outfil,afname,refile,
     $      tag,noantg,edge,core,elemnt,dopant,
     $      x,y,z,cell,dmax,st,fullcl,atlis,
     $      percnt,gasses,qvect,egr,anot,
     $      logic,stdout,vaxflg,expnd)
c=====================================================================
c  atoms module 1:  initialize, read input file, error checking
c=====================================================================
c  this module consists of the following subroutines and functions:
c     readin atchck atinit atinpt atspec dopfix getatm groups origin
c     rh2hex schfix settng spcchk systm
c=====================================================================
      implicit integer(i-n)
      implicit real(a-h,o-z)
c      implicit double precision(a-h,o-z)

c      parameter (iat=50, natx=800, ntitx=9, ndopx=4, ngeomx=800)
c      parameter (neptx=2**11)

      character*2  elemnt(iat)
      character*2  edge, dopant(iat,ndopx), vrsion*9, test
      character*10 spcgrp, inpgrp, tag(iat), core, geodat, noantg(iat)
      character*72 title(ntitx),outfil,afname,outf,refile
      character*74 messg
      logical      logic(nlogx), stdout, vaxflg, expnd, shift
      complex      anot(neptx)
      dimension    ipt(iat), iptful(iat), idop(iat),
     $             ngeom(ngeomx), nrefl(3)
      dimension    x(iat), y(iat), z(iat)
      dimension    cell(6), qvect(3), gasses(3)
      dimension    st(iat,192,3), fullcl(iat,192,3),  atlis(natx,8)
      dimension    percnt(iat,ndopx)

      parameter(nshwrn=4)
      character*74 shwarn(nshwrn)
      logical      shft

 4000 format(35('*-'),'*')
 4010 format(1x,'* ',a75)
 4020 format(1x,' ')
 4100 format(1x,'* This feff.inp file generated by ATOMS, version ',
     $       a9,/,' * ATOMS written by and copyright (c) Bruce Ravel',
     $       ', 1992-1999',/)

c------------------------------------------------------------
c  initialize everything and read the input file
c  then check the consistency of the input values and
c  determine system from cell constants
c      call messag('  initializing...')
      call atinit(iat,natx,ntitx,ndopx,ngeomx,neptx,nlogx,
     $            title,elemnt,tag,noantg,spcgrp,edge,core,
     $            dopant,outfil,afname,geodat,refile,
     $            iatom,ibasis,dmax,ispa,iperm,idop,ngeom,iedge,iabs,
     $            ipt,iptful,isyst,nepts,nrefl,nnoan,
     $            x,y,z,cell,st,fullcl,atlis,
     $            percnt,gasses,qvect,egr,anot,
     $            logic,stdout)

c      call messag('  reading atom.inp...')
      call atinpt(iat,ntitx,ndopx,nlogx,
     $            title,ntit,iatom,ibasis,iabs,dmax,ispa,iperm,
     $            idop,iedge,nepts,nrefl,isystm,nnoan,
     $            elemnt,tag,noantg,edge,core,spcgrp,inpgrp,
     $            outfil,shwarn,afname,refile,dopant,
     $            x,y,z,cell,percnt,gasses,qvect,egr,
     $            logic, stdout, expnd, shift)

      if (logic(1)) goto 99

c  this is a lame work-around for not yet having headers in readin
      call igtisp(ispa)
c      call messag('  consistancy checks...')
      call atchck(iat,ndopx,core,dopant,edge,
     $            iatom,ibasis,ispa,idop,
     $            x,y,z,cell,dmax,gasses,qvect)

c a few more chores before leaving
      nsites = iatom
      if (logic(2)) nsites=ibasis

      inquire(file=outfil,exist=logic(12))
      if (logic(6)) inquire(file=geodat,exist=logic(13))

      test = 'ab'
      outf=outfil
      call case(test,outf)
      if (stdout) then
          write(ifeff,4100)vrsion
c          call origin(spcgrp, warn, wrning)
      else
          if (outf.eq.'list') then
              inquire(file='atoms.lis',exist=logic(12))
          else
              if (.not.vaxflg) then
                  open(unit=ifeff,file=outfil,status='unknown')
              else
                  open(unit=ifeff,file=outfil,status='new')
              endif
              write(ifeff,4100)vrsion
          endif
      endif

c             --- give warning about space groups that need shift
c      call origin(spcgrp, warn, wrning)
      call gtshft(shft,shwarn)
      if (shft) then
          if (ifeff.ne.6) then
              write(messg,4000)
c              call messag(messg)
              call messag(' ')
              call messag(' *** Warning:')
          endif
          do 20 i=1,nshwrn
            if (ifeff.eq.6) then
                call messag('* '//shwarn(i))
            else
                call messag(shwarn(i))
                write(ifeff,4010)shwarn(i)
            endif
 20       continue
          write(ifeff,4020)
          if (ifeff.ne.6) then
              write(messg,4000)
c              call messag(messg)
              call messag(' ')
          endif
          ierr = 2
      endif

99    continue

      return
c  end of module readin
      end

      subroutine igtisp(isp)
      include 'atparm.h'
      include 'crystl.h'
      isp = ispa
      return
      end

      subroutine gtshft(shft,shw)
      logical shft
      character*74 shw(4)
      include 'atparm.h'
      include 'crystl.h'
      shft = shift
      shw(1) = shwarn(1)
      shw(2) = shwarn(2)
      shw(3) = shwarn(3)
      shw(4) = shwarn(4)
      return
      end
