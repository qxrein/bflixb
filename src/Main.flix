enum Expr {
    case StringLit(String)
    case FunCall(String, List[Expr])
}

enum BeamInstr {
    case Move(String, String)
    case CallExt(String)
    case Return
}

def parseSimple(input: String): Expr =
    if (String.startsWith(prefix = "print(\"", input))
        let content = String.slice(start = 7, end = String.length(input) - 2, input);
        Expr.FunCall("print", Expr.StringLit(content) :: Nil)
    else
        Expr.StringLit("error")

def generateBeam(expr: Expr): List[BeamInstr] = match expr {
    case Expr.FunCall("print", args) => match args {
        case Expr.StringLit(s) :: Nil =>
            BeamInstr.Move("\"${s}\"", "{x,1}") ::
            BeamInstr.CallExt("io:format/1") ::
            BeamInstr.Return :: Nil
        case _ => Nil
    }
    case _ => Nil
}

def instrToString(instr: BeamInstr): String = match instr {
    case BeamInstr.Move(src, dst) => "    {move, ${src}, ${dst}}"
    case BeamInstr.CallExt(func) => "    {call_ext, 1, {extfunc, ${func}}}"
    case BeamInstr.Return => "    return"
}

def joinStrings(sep: String, strs: List[String]): String = match strs {
    case Nil => ""
    case s :: Nil => s
    case s :: rest => s + sep + joinStrings(sep, rest)
}

def emitBeam(instrs: List[BeamInstr]): String =
    let instrStrs = List.map(instrToString, instrs);
    joinStrings("\n", instrStrs)

def generateModule(moduleName: String, instrs: List[BeamInstr]): String =
    "{module, ${moduleName}}.\n" +
    "{exports, [{start, 0}]}.\n" +
    "{labels, 2}.\n" +
    "\n" +
    "{function, start, 0, 2}.\n" +
    "  {label, 1}.\n" +
    emitBeam(instrs) + "\n"

def compile(source: String): String =
    let ast = parseSimple(source);
    let beamInstrs = generateBeam(ast);
    generateModule("hello_world", beamInstrs)

def main(): Unit \ IO =
    let source = "print(\"Hello World\")";
    let compiled = compile(source);
    println("Generated BEAM bytecode:");
    println(compiled)
