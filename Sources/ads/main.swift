import GoogleDocsLib

@available(macOS 13.0, *)
@main
struct ADSMain {
    static func main() async {
        await RootCommand.main()
    }
}
