import { Arch } from "builder-util";
import { Target } from "../core";
import { PlatformPackager } from "../platformPackager";
export declare class ArchiveTarget extends Target {
    readonly outDir: string;
    private readonly packager;
    readonly options: any;
    constructor(name: string, outDir: string, packager: PlatformPackager<any>);
    build(appOutDir: string, arch: Arch): Promise<any>;
}
