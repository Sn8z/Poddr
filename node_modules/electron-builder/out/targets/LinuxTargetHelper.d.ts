import { LinuxPackager } from "../linuxPackager";
import { LinuxConfiguration, LinuxTargetSpecificOptions } from "../options/linuxOptions";
export declare const installPrefix = "/opt";
export declare class LinuxTargetHelper {
    private packager;
    readonly icons: Promise<Array<Array<string>>>;
    maxIconPath: string | null;
    constructor(packager: LinuxPackager);
    private computeDesktopIcons();
    private iconsFromDir(iconDir);
    private getIcns();
    getDescription(options: LinuxConfiguration): string;
    computeDesktopEntry(targetSpecificOptions: LinuxTargetSpecificOptions, exec?: string, destination?: string | null, extra?: {
        [key: string]: string;
    }): Promise<string>;
    private createFromIcns(tempDir);
    private createMappings(tempDir);
}
