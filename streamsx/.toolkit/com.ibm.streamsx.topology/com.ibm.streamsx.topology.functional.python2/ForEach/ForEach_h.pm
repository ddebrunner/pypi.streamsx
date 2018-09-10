# SPL_CGT_INCLUDE: ../../opt/python/codegen/py_enable_cr.cgt

package ForEach_h;
use strict; use Cwd 'realpath';  use File::Basename;  use lib dirname(__FILE__);  use SPL::Operator::Instance::OperatorInstance; use SPL::Operator::Instance::Annotation; use SPL::Operator::Instance::Context; use SPL::Operator::Instance::Expression; use SPL::Operator::Instance::ExpressionTree; use SPL::Operator::Instance::ExpressionTreeEvaluator; use SPL::Operator::Instance::ExpressionTreeVisitor; use SPL::Operator::Instance::ExpressionTreeCppGenVisitor; use SPL::Operator::Instance::InputAttribute; use SPL::Operator::Instance::InputPort; use SPL::Operator::Instance::OutputAttribute; use SPL::Operator::Instance::OutputPort; use SPL::Operator::Instance::Parameter; use SPL::Operator::Instance::StateVariable; use SPL::Operator::Instance::TupleValue; use SPL::Operator::Instance::Window; 
sub main::generate($$) {
   my ($xml, $signature) = @_;  
   print "// $$signature\n";
   my $model = SPL::Operator::Instance::OperatorInstance->new($$xml);
   unshift @INC, dirname ($model->getContext()->getOperatorDirectory()) . "/../impl/nl/include";
   $SPL::CodeGenHelper::verboseMode = $model->getContext()->isVerboseModeOn();
   print '/* Additional includes go here */', "\n";
   print '#include "splpy_funcop.h"', "\n";
   print "\n";
   print 'using namespace streamsx::topology;', "\n";
   print "\n";
   SPL::CodeGen::headerPrologue($model);
   print "\n";
   print "\n";
   print 'class MY_OPERATOR : public MY_BASE_OPERATOR, public DelegatingStateHandler', "\n";
   print '{', "\n";
   print 'public:', "\n";
   print '  // Constructor', "\n";
   print '  MY_OPERATOR();', "\n";
   print "\n";
   print '  // Destructor', "\n";
   print '  virtual ~MY_OPERATOR(); ', "\n";
   print "\n";
   print '  // Notify termination', "\n";
   print '  void prepareToShutdown(); ', "\n";
   print "\n";
   print '  // Tuple processing for non-mutating ports', "\n";
   print '  void process(Tuple const & tuple, uint32_t port);', "\n";
   print "\n";
   print 'private:', "\n";
   print '  SplpyOp * op() { return funcop_; }', "\n";
   print '  ', "\n";
   print '  // Members', "\n";
   print '  // Control for interaction with Python', "\n";
   print '  SplpyFuncOp *funcop_;', "\n";
   print '  ', "\n";
   print '  PyObject *pyInStyleObj_;', "\n";
   print "\n";
    
    # Enable or disable checkpointing, including support for the necessary locking.
   
    # Checkpointing should be enabled if the operator is in a consistent region,
    # or has checkpointing configured.  Also, the operator must be stateful,
    # otherwise no checkpointing is needed.
   
    # This will generally be @included in the declaration of an SPL operator
    # template.  It create static const values indicating whether the operator
    # instance is in a consistent region, and whether it is checkpointing.
    # It also provides some typedefs for types to be used by the operator
    # to support checkpointing and consistent region.
   
    my $isInConsistentRegion = $model->getContext()->getOptionalContext("ConsistentRegion");
    my $ckptKind = $model->getContext()->getCheckpointingKind();
    my $pyStateful = $model->getParameterByName("pyStateful");
    my $stateful = 0;
    if (defined($pyStateful)) {
      $stateful = $pyStateful->getValueAt(0)->getSPLExpression() eq "true";
    }
    else {
      # no pyStateful parameter.  Try calling splpy_OperatorCallable().
      if (defined &splpy_OperatorCallable) {
        $stateful = splpy_OperatorCallable() eq 'class'
      }
    }
   
    my $isCheckpointing = $stateful && ($isInConsistentRegion or $ckptKind ne "none");
   print "\n";
   print '  // True if this operator is in a consistent region.', "\n";
   print '  static const bool isInConsistentRegion = ';
   print  $isInConsistentRegion ? "true" :" false" ;
   print ';', "\n";
   print '  // True if operator is stateful and checkpoint is enabled, ', "\n";
   print '  // whether directly or through consistent region.', "\n";
   print '  static const bool isCheckpointing = ';
   print $isCheckpointing ? "true" : "false" ;
   print ';', "\n";
   print "\n";
   print '  typedef OptionalConsistentRegionContextImpl<isInConsistentRegion> OptionalConsistentRegionContext;', "\n";
   print '  typedef OptionalConsistentRegionContext::Permit AutoConsistentRegionPermit;', "\n";
   print '  typedef OptionalAutoLockImpl<isCheckpointing> OptionalAutoLock;', "\n";
   print "\n";
   print "\n";
   print '}; ', "\n";
   print "\n";
   SPL::CodeGen::headerEpilogue($model);
   print "\n";
   print "\n";
   CORE::exit $SPL::CodeGen::USER_ERROR if ($SPL::CodeGen::sawError);
}
1;
