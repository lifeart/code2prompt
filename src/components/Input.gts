import { Component } from '@lifeart/gxt';

export class Input extends Component<{
  Args: { 
    value: string; 
    onInput?: (e: Event) => void; 
    onChange?: (e: Event) => void 
  } | { 
    checked: boolean; 
    onInput?: (e: Event) => void; 
    onChange?: (e: Event) => void 
  };
  Element: HTMLInputElement
}> {
  onInput = (e: Event) => {
    this.args.onInput?.(e);
  }
  onChange = (e: Event) => {
    this.args.onChange?.(e);
  }
  <template>
    <input
      value={{@value}}
      checked={{@checked}}
      type='text'
      class='bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500'
      {{on 'input' this.onInput}}
      {{on 'change' this.onChange}}
      ...attributes
    />
  </template>
}
