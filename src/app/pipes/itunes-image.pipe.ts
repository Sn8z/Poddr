import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'itunesImage' })
export class ItunesImage implements PipeTransform {
  transform(value: string): string {
    return value.replace("60x60", "250x250");
  }
}