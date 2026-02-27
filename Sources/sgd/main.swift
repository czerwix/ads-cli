import GoogleDocsLib

@available(macOS 13.0, *)
@main
struct SGDMain {
    static func main() async {
        await RootCommand.main()
    }
}
