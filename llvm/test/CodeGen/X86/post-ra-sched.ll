; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386 -mcpu=pentium4 | FileCheck %s --check-prefix=PENTIUM4
; RUN: llc < %s -mtriple=i386 -mcpu=pentium4m | FileCheck %s --check-prefix=PENTIUM4
; RUN: llc < %s -mtriple=i386 -mcpu=pentium-m | FileCheck %s
; RUN: llc < %s -mtriple=i386 -mcpu=prescott | FileCheck %s
; RUN: llc < %s -mtriple=i386 -mcpu=nocona | FileCheck %s
;
; Verify that scheduling puts some distance between a load feeding into
; the address of another load, and that second load.  This currently
; happens during the post-RA-scheduler, which should be enabled by
; default with the above specified cpus.

; Pentium4 is the default 32-bit CPU on Linux and currently has the postRA
; scheduler disabled. Leaving the command lines in place in case we change that.

@ptrs = external global [0 x i32*], align 4
@idxa = common global i32 0, align 4
@idxb = common global i32 0, align 4
@res = common global i32 0, align 4

define void @addindirect() {
; PENTIUM4-LABEL: addindirect:
; PENTIUM4:       # %bb.0: # %entry
; PENTIUM4-NEXT:    movl idxa, %eax
; PENTIUM4-NEXT:    movl ptrs(,%eax,4), %eax
; PENTIUM4-NEXT:    movl idxb, %ecx
; PENTIUM4-NEXT:    movl ptrs(,%ecx,4), %ecx
; PENTIUM4-NEXT:    movl (%ecx), %ecx
; PENTIUM4-NEXT:    addl (%eax), %ecx
; PENTIUM4-NEXT:    movl %ecx, res
; PENTIUM4-NEXT:    retl
;
; CHECK-LABEL: addindirect:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl idxb, %ecx
; CHECK-NEXT:    movl idxa, %eax
; CHECK-NEXT:    movl ptrs(,%ecx,4), %ecx
; CHECK-NEXT:    movl ptrs(,%eax,4), %eax
; CHECK-NEXT:    movl (%ecx), %ecx
; CHECK-NEXT:    addl (%eax), %ecx
; CHECK-NEXT:    movl %ecx, res
; CHECK-NEXT:    retl
entry:
  %0 = load i32, i32* @idxa, align 4
  %arrayidx = getelementptr inbounds [0 x i32*], [0 x i32*]* @ptrs, i32 0, i32 %0
  %1 = load i32*, i32** %arrayidx, align 4
  %2 = load i32, i32* %1, align 4
  %3 = load i32, i32* @idxb, align 4
  %arrayidx1 = getelementptr inbounds [0 x i32*], [0 x i32*]* @ptrs, i32 0, i32 %3
  %4 = load i32*, i32** %arrayidx1, align 4
  %5 = load i32, i32* %4, align 4
  %add = add i32 %5, %2
  store i32 %add, i32* @res, align 4
  ret void
}
