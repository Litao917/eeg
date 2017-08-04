classdef ConstraintDiagnosticFactory
    %ConstraintDiagnosticFactory   Generates ConstraintDiagnostic objects
    %   This class provides static methods that assist with generating
    %   matlab.unittest.diagnostics.ConstraintDiagnostic objects. The primary
    %   use case is for the return value of the getDiagnosticFor() and
    %   getNegativeDiagnosticFor() methods when developing classes derived from
    %   matlab.unittest.constraints.Constraint or matlab.unittest.constraints.Comparator.
    %   The matlab.unittest.internal.diagnostics.DiagnosticSense
    %   enumeration defines the enumerations for positive and negative diagnostics.
    %
    %   See also
    %       matlab.unittest.internal.diagnostics.DiagnosticSense
    %       matlab.unittest.constraints.Constraint
    %       matlab.unittest.constraints.Comparator
    %       matlab.unittest.diagnostics.ConstraintDiagnostic
    
    %   Copyright 2010-2013 The MathWorks, Inc.
    
    methods (Static, Access = private)
        function diag = constructAppropriateDiagnostic(requirement, isSatisfied)
            %constructAppropriateDiagnostic   Construct the appropriate class diagnostic
            %   DIAG = constructAppropriateDiagnostic(REQUIREMENT) uses REQUIREMENT to
            %   determine what class of diagnostic, DIAG, to construct. If
            %   a matlab.unittest.constraints.Comparator or matlab.unittest.constraints.Tolerance,
            %   then an unpopulated matlab.unittest.internal.diagnostics.RecursiveConstraintDiagnostic
            %   is generated; otherwise, an unpopulated  matlab.unittest.diagnostics.ConstraintDiagnostic
            %   is generated.
            %
            %   This is a private method wrapped by more convenient public methods.
            
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.RecursiveConstraintDiagnostic;
            
            if isa(requirement, 'matlab.unittest.constraints.Comparator') || ...
                    isa(requirement, 'matlab.unittest.constraints.Tolerance')
                diag = RecursiveConstraintDiagnostic();
                diag.DisplayRecursivePath = ~isSatisfied;
            else
                diag = ConstraintDiagnostic();
            end
        end
        
        function diag = createGenericDiagnostic(requirement, ...
                isSatisfied, consType, actVal, expVal)
            %createGenericDiagnostic   Create diagnostic from a generic template
            %   DIAG = createGenericDiagnostic(REQUIREMENT, ISSATISFIED, CONSTYPE,
            %   ACTVAL, EXPVAL) creates a generic positive or negated
            %   ConstraintDiagnostic, DIAG, for the constraint or comparator defined by
            %   REQUIREMENT. The ISSATISFIED flag determines whether the DIAG says it
            %   passed or not. The CONSTYPE is the PositiveDiagnostic or
            %   NegativeDiagnostic enumeration, which determines whether the DIAG is
            %   being generated for a positive (getDiagnosticFor) or negated
            %   (getNegativeDiagnosticFor) situation. ACTVAL and EXPVAL are the actual
            %   and expected values of the constraint or comparator.  When EXPVAL is
            %   omitted, the DisplayExpVal property of the returned DIAG is turned off.
            %
            %   This is a private method wrapped by more convenient public methods.
            
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.createConstraintDiagnosticDescription;
            
            validateattributes(requirement, ...
                {'matlab.unittest.constraints.Constraint', ...
                'matlab.unittest.constraints.Comparator', ...
                'matlab.unittest.constraints.Tolerance', ...
                'matlab.unittest.constraints.ActualValueProxy'}, ...
                {'scalar'}, '', 'constraint');
            validateattributes(consType, ...
                {'matlab.unittest.internal.diagnostics.DiagnosticSense'}, ...
                {'scalar'}, '', 'consType');
            
            diag = ConstraintDiagnosticFactory.constructAppropriateDiagnostic(requirement, isSatisfied);
            diag.DisplayDescription = true;
            diag.Description = createConstraintDiagnosticDescription(requirement, isSatisfied, consType);
            
            diag.DisplayConditions = ~isSatisfied;
            diag.DisplayActVal     = ~isSatisfied;
            diag.ActVal            =  actVal;
            
            if (nargin == 5)
                diag.DisplayExpVal = ~isSatisfied;
                diag.ExpVal        = expVal;
            end
        end
        
    end
    
    methods (Static)
        function diag = generatePassingDiagnostic(requirement, consType)
            %generatePassingDiagnostic   Generate a generic passing ConstraintDiagnostic
            %   DIAG = generatePassingDiagnostic(REQUIREMENT,CONSTYPE) generates a
            %   passing ConstraintDiagnostic when REQUIREMENT is derived from
            %   Constraint or it generates a passing RecursiveConstraintDiagnostic when
            %   REQUIREMENT is derived from Comparator.  When called from a
            %   getDiagnosticFor() method, CONSTYPE should be the
            %   DiagnosticSense.Positive enumeration; when called
            %   from getNegativeDiagnosticFor(), it should be the
            %   DiagnosticSense.Negative enumeration.
            %
            %   Examples:
            %       % From within a Constraint's getDiagnosticFor() method
            %       function diag = getDiagnosticFor(constraint, actual)
            %           import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            %           import matlab.unittest.internal.diagnostics.DiagnosticSense;
            %           if constraint.satisfiedBy(actual)
            %               diag = ConstraintDiagnosticFactory.generatePassingDiagnostic( ...
            %                   constraint, DiagnosticSense.Positive);
            %           else
            %               ... see help on generateFailingDiagnostic()
            %           end
            %       end
            %
            %       % From within a Constraint's getNegativeDiagnosticFor() method
            %       function diag = getNegativeDiagnosticFor(constraint, actual)
            %           import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            %           import matlab.unittest.internal.diagnostics.DiagnosticSense;
            %           if constraint.satisfiedBy(actual)
            %               ... see help on generateFailingDiagnostic()
            %           else
            %               diag = ConstraintDiagnosticFactory.generatePassingDiagnostic( ...
            %                   constraint, DiagnosticSense.Negative);
            %           end
            %       end
            %
            %   See also
            %       matlab.unittest.constraints.Constraint,
            %       matlab.unittest.constraints.Comparator,
            %       matlab.unittest.diagnostics.ConstraintDiagnostic,
            
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            
            diag = ConstraintDiagnosticFactory.createGenericDiagnostic(requirement, true, consType, []);
        end
        
        function diag = generateFailingDiagnostic(requirement, consType, actVal, expVal)
            %generateFailingDiagnostic   Generate a generic failing ConstraintDiagnostic
            %   DIAG = generateFailingDiagnostic(REQUIREMENT,CONSTYPE, ACTVAL, EXPVAL)
            %   generates a failing ConstraintDiagnostic when REQUIREMENT is derived
            %   from Constraint or a failing RecursiveConstraintDiagnostic when
            %   REQUIREMENT is derived from Comparator. When called from a
            %   getDiagnosticFor() method, CONSTYPE should be the
            %   DiagnosticSense.Positive enumeration; when called
            %   from getNegativeDiagnosticFor(), it should be the
            %   DiagnosticSense.Negative enumeration.  ACTVAL and
            %   EXPVAL are the actual and expected (specified) values from the
            %   constraint. If EXPVAL is omitted, the generated DIAG turns off the
            %   DisplayExpVal property.
            %
            %   Examples:
            %       % From within a Constraint's getDiagnosticFor() method
            %       function diag = getDiagnosticFor(constraint, actual)
            %           import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            %           import matlab.unittest.internal.diagnostics.DiagnosticSense;
            %           if constraint.satisfiedBy(actual)
            %               ... see help on generatePassingDiagnostic()
            %           else
            %               diag = ConstraintDiagnosticFactory.generateFailingDiagnostic( ...
            %                   constraint, ...
            %                   DiagnosticSense.Positive, ...
            %                   actual, ...
            %                   optionalExpected);
            %               ... make modifications to diag
            %               ... see help on matlab.unittest.diagnostics.ConstraintDiagnostic
            %           end
            %       end
            %
            %       % From within a Constraint's getNegativeDiagnosticFor() method
            %       function diag = getNegativeDiagnosticFor(constraint, actual)
            %           import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            %           import matlab.unittest.internal.diagnostics.DiagnosticSense;
            %           if constraint.satisfiedBy(actual)
            %               diag = ConstraintDiagnosticFactory.generateFailingDiagnostic( ...
            %                   constraint, ...
            %                   DiagnosticSense.Negative,
            %                   actual, ...
            %                   optionalExpected);
            %               ... make modifications to diag
            %               ... see help on matlab.unittest.diagnostics.ConstraintDiagnostic
            %           else
            %               ... see help on generatePassingDiagnostic()
            %           end
            %
            %   See also
            %       matlab.unittest.constraints.Constraint,
            %       matlab.unittest.constraints.Comparator,
            %       matlab.unittest.diagnostics.ConstraintDiagnostic,
            
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            
            if (nargin == 3)
                diag = ConstraintDiagnosticFactory.createGenericDiagnostic(requirement, false, consType, actVal);
            else
                diag = ConstraintDiagnosticFactory.createGenericDiagnostic(requirement, false, consType, actVal, expVal);
            end
        end
    end
    
    methods (Static, Hidden)
        function diag = generateSizeMismatchDiagnostic(requirement, consType, actVal, expVal)
            %generateSizeMismatchDiagnostic   Generate a failing ConstraintDiagnostic when actual and expected sizes differ
            %   DIAG = generateSizeMismatchDiagnostic(REQUIREMENT, CONSTYPE, ACTVAL, EXPVAL)
            %   generates a failing ConstraintDiagnostic when REQUIREMENT is derived
            %   from Constraint or a failing RecursiveConstraintDiagnostic when
            %   REQUIREMENT is derived from Comparator. When called from a
            %   getDiagnosticFor() method, CONSTYPE should be the
            %   DiagnosticSense.Positive enumeration; when called
            %   from getNegativeDiagnosticFor(), it should be the
            %   DiagnosticSense.Negative enumeration.
            
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
           
            diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(requirement, ...
                consType, actVal, expVal);
            diag.Description = getString(message('MATLAB:unittest:ConstraintDiagnostic:SizeCheckFailed'));
            diag.DisplayActVal = false;
            diag.DisplayExpVal = false;
            subDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(requirement, ...
                consType, size(actVal), size(expVal));
            subDiag.Description  = getString(message('MATLAB:unittest:ConstraintDiagnostic:SizeMismatch'));
            subDiag.ActValHeader = getString(message('MATLAB:unittest:ConstraintDiagnostic:ActualSize', class(actVal)));
            subDiag.ExpValHeader = getString(message('MATLAB:unittest:ConstraintDiagnostic:ExpectedSize', class(expVal)));
            diag.addCondition(subDiag);
        end
        
        function diag = generateClassMismatchDiagnostic(requirement, consType, actVal, expVal)
            %generateClassMismatchDiagnostic   Generate a failing ConstraintDiagnostic when actual and expected classes differ
            %   DIAG = generateClassMismatchDiagnostic(REQUIREMENT, CONSTYPE, ACTVAL, EXPVAL)
            %   generates a failing ConstraintDiagnostic when REQUIREMENT is derived
            %   from Constraint or a failing RecursiveConstraintDiagnostic when
            %   REQUIREMENT is derived from Comparator. When called from a
            %   getDiagnosticFor() method, CONSTYPE should be the
            %   DiagnosticSense.Positive enumeration; when called
            %   from getNegativeDiagnosticFor(), it should be the
            %   DiagnosticSense.Negative enumeration.
            
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            
            diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(requirement, ...
                consType, actVal, expVal);
            diag.Description = getString(message('MATLAB:unittest:ConstraintDiagnostic:ClassCheckFailed'));
            diag.DisplayActVal = false;
            diag.DisplayExpVal = false;
            subDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(requirement, ...
                consType, class(actVal), class(expVal));
            subDiag.Description  = getString(message('MATLAB:unittest:ConstraintDiagnostic:ClassMismatch'));
            subDiag.ActValHeader = getString(message('MATLAB:unittest:ConstraintDiagnostic:ActualClass'));
            subDiag.ExpValHeader = getString(message('MATLAB:unittest:ConstraintDiagnostic:ExpectedClass'));
            diag.addCondition(subDiag);
        end
        
        function diag = generateSparsityMismatchDiagnostic(requirement, consType, actVal, expVal)
            %generateSparsityMismatchDiagnostic   Generate a failing ConstraintDiagnostic when actual and expected sparsity differ
            %   DIAG = generateSparsityMismatchDiagnostic(REQUIREMENT, CONSTYPE, ACTVAL, EXPVAL)
            %   generates a failing ConstraintDiagnostic when REQUIREMENT is derived
            %   from Constraint or a failing RecursiveConstraintDiagnostic when
            %   REQUIREMENT is derived from Comparator. When called from a
            %   getDiagnosticFor() method, CONSTYPE should be the
            %   DiagnosticSense.Positive enumeration; when called
            %   from getNegativeDiagnosticFor(), it should be the
            %   DiagnosticSense.Negative enumeration.
            
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            
            if issparse(actVal)
                actSparsity = getString(message('MATLAB:unittest:ConstraintDiagnostic:SparseAttribute'));
            else
                actSparsity = getString(message('MATLAB:unittest:ConstraintDiagnostic:FullAttribute'));
            end
            if issparse(expVal)
                expSparsity = getString(message('MATLAB:unittest:ConstraintDiagnostic:SparseAttribute'));
            else
                expSparsity = getString(message('MATLAB:unittest:ConstraintDiagnostic:FullAttribute'));
            end
            
            diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(requirement, ...
                consType, actVal, expVal);
            diag.Description = getString(message('MATLAB:unittest:ConstraintDiagnostic:SparsityCheckFailed'));
            diag.DisplayActVal = false;
            diag.DisplayExpVal = false;
            subDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(requirement, ...
                consType, actSparsity, expSparsity);
            subDiag.Description  = getString(message('MATLAB:unittest:ConstraintDiagnostic:SparsityMismatch'));
            subDiag.ActValHeader = getString(message('MATLAB:unittest:ConstraintDiagnostic:ActualSparsity'));
            subDiag.ExpValHeader = getString(message('MATLAB:unittest:ConstraintDiagnostic:ExpectedSparsity'));
            diag.addCondition(subDiag);
        end
        
        function diag = generateComplexityMismatchDiagnostic(requirement, consType, actVal, expVal)
            %generateComplexityMismatchDiagnostic   Generate a failing ConstraintDiagnostic when actual and expected complexity differ
            %   DIAG = generateComplexityMismatchDiagnostic(REQUIREMENT, CONSTYPE, ACTVAL, EXPVAL)
            %   generates a failing ConstraintDiagnostic when REQUIREMENT is derived
            %   from Constraint or a failing RecursiveConstraintDiagnostic when
            %   REQUIREMENT is derived from Comparator. When called from a
            %   getDiagnosticFor() method, CONSTYPE should be the
            %   DiagnosticSense.Positive enumeration; when called
            %   from getNegativeDiagnosticFor(), it should be the
            %   DiagnosticSense.Negative enumeration.
            
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            
            if isreal(actVal)
                actComplexity = getString(message('MATLAB:unittest:ConstraintDiagnostic:RealAttribute'));
            else
                actComplexity = getString(message('MATLAB:unittest:ConstraintDiagnostic:ComplexAttribute'));
            end
            if isreal(expVal)
                expComplexity = getString(message('MATLAB:unittest:ConstraintDiagnostic:RealAttribute'));
            else
                expComplexity = getString(message('MATLAB:unittest:ConstraintDiagnostic:ComplexAttribute'));
            end
            
            diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(requirement, ...
                consType, actVal, expVal);
            diag.Description = getString(message('MATLAB:unittest:ConstraintDiagnostic:ComplexityCheckFailed'));
            diag.DisplayActVal = false;
            diag.DisplayExpVal = false;
            subDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(requirement, ...
                consType, actComplexity, expComplexity);
            subDiag.Description  = getString(message('MATLAB:unittest:ConstraintDiagnostic:ComplexityMismatch'));
            subDiag.ActValHeader = getString(message('MATLAB:unittest:ConstraintDiagnostic:ActualComplexity'));
            subDiag.ExpValHeader = getString(message('MATLAB:unittest:ConstraintDiagnostic:ExpectedComplexity'));
            diag.addCondition(subDiag);
        end
    end
end

% LocalWords:  ISSATISFIED CONSTYPE ACTVAL EXPVAL
