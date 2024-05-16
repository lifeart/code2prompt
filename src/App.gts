import { Component, tracked } from '@lifeart/gxt';
import { Input } from '@/components/Input';
import { autofocus } from '@/modifiers/autofocus';
import { retrieveGithubRepoInfo } from './utils/repo-loader';
import { read, write } from './utils/persistent';
import { dirsToSkip, filesToSkip, knownExtensions } from './utils/constants';
import { tpl } from './utils/tpl';
import { toFile } from './utils/serializer';
import { loadFile } from './utils/file-loader';

export default class App extends Component {
  @tracked token = read<string>('token', '');
  updateToken = (e: Event) => {
    this.token = (e.target as HTMLInputElement).value;
    write('token', this.token);
  };
  @tracked
  name = read<string>('name', '');
  @tracked result = '';
  @tracked isLoading = false;
  @tracked knownExtensions = knownExtensions;
  @tracked filesToSkip = filesToSkip;
  @tracked dirsToSkip = dirsToSkip;
  epoch = 0;
  get dirsToSkipAsString() {
    return this.dirsToSkip.join(', ');
  }
  get filesToSkipAsString() {
    return this.filesToSkip.join(', ');
  }
  get knownExtensionsAsString() {
    return this.knownExtensions.join(', ');
  }
  updateName = (e: Event) => {
    const node = e.target as HTMLInputElement;
    if (this.name === node.value) return;
    if (this.isLoading) {
      node.value = this.name;
      return;
    }
    this.name = node.value;
    write('name', this.name);
  };
  loadData = async () => {
    this.epoch++;
    const currentEpoch = this.epoch;
    while (this.isLoading) {
      if (currentEpoch !== this.epoch) return;
      await new Promise((resolve) => setTimeout(resolve, 100));
    }
    this.result = '';
    this.isLoading = true;
    try {
      retrieveGithubRepoInfo(this.name, this.token, {
        dirsToSkip: this.dirsToSkip,
        filesToSkip: this.filesToSkip,
        knownExtensions: this.knownExtensions,
        isAlive: () => {
          return currentEpoch === this.epoch;
        },
      })
        .then((result) => {
          this.result = result;
          this.isLoading = false;
        })
        .catch((e) => {
          this.result = String(e);
          this.isLoading = false;
        });
    } catch (e) {
      this.result = String(e);
      this.isLoading = false;
    }
  };
  updateList = (
    key: 'knownExtensions' | 'dirsToSkip' | 'filesToSkip',
    e: Event,
  ) => {
    const node = e.target as HTMLInputElement;
    const values = node.value
      .split(',')
      .map((item) => item.trim())
      .filter(Boolean);

    write(key, values);
    this[key] = values;
  };
  loadFromFile = async (e: Event) => {
    const file = (e.target as HTMLInputElement).files?.[0];
    if (!file) return;
    try {
      this.result = await loadFile(file, {
        dirsToSkip: this.dirsToSkip,
        filesToSkip: this.filesToSkip,
        knownExtensions: this.knownExtensions,
      });
    } catch (e) {
      this.result = String(e);
    }
   
  };
  <template>
    <section style.min-width='600px'>
      <h2 class='text-orange-300' style.margin-bottom='20px'>
        Hello, Human!
      </h2>
      <p>
        <div class='flex justify-between items-center'>
          <label for="file" class='m-2 text-white'>Upload zip file</label>
          <input id="file" type='file' {{on 'change' this.loadFromFile}} />
        </div>
        <div class='flex justify-between items-center'>
          <label class='m-2 text-white'>OR</label>
        </div>
        <div class='flex justify-between items-center'>
          <Input
            class='m-2'
            aria-label='Github token'
            placeholder='Github token'
            @value={{this.token}}
            @onInput={{this.updateToken}}
          />
        </div>
        <div class='flex justify-between items-center'>
          <Input
            class='m-2 flex-grow'
            aria-label='Github repo link'
            placeholder='Github repo link, like: https://github.com/lifeart/glimmerx-workshop/tree/master '
            @value={{this.name}}
            @onChange={{this.updateName}}
            disabled={{this.isLoading}}
            {{autofocus}}
          />
          <button
            class='m-2 p-2 bg-blue-500 text-white rounded-lg shadow-lg hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-300'
            style.cursor={{if this.isLoading 'progress' 'pointer'}}
            type='button'
            {{on 'click' this.loadData}}
          >
            Submit
          </button>
        </div>
        <div class='flex justify-between items-center'>
          <details class='m-2 w-full'>
            <summary class='cursor-pointer text-blue-500'>Extra Configuration</summary>
            <div class='p-2 border rounded'>
              <label id='dirs-to-skip' class='text-white'>Exclude folders
                (comma-separated)</label>
              <Input
                class='m-2'
                id='dirs-to-skip'
                @value={{this.dirsToSkipAsString}}
                placeholder='Exclude folders (comma-separated)'
                @onChange={{fn this.updateList 'dirsToSkip'}}
              />
              <label id='files-to-skip' class='text-white'>Exclude files
                (comma-separated)</label>
              <Input
                class='m-2'
                id='files-to-skip'
                @value={{this.filesToSkipAsString}}
                placeholder='Exclude files (comma-separated)'
                title='Exclude folders (comma-separated)'
                @onChange={{fn this.updateList 'filesToSkip'}}
              />
              <label id='known-extensions' class='text-white'>Include extensions
                (comma-separated)</label>
              <Input
                class='m-2'
                id='known-extensions'
                @value={{this.knownExtensionsAsString}}
                placeholder='Include extensions (comma-separated)'
                title='Exclude folders (comma-separated)'
                @onChange={{fn this.updateList 'knownExtensions'}}
              />
            </div>
          </details>
        </div>
        {{#if this.isLoading}}
          <span class='m-2 text-white'>Loading...</span>
        {{/if}}
        <div class='flex justify-between items-center'>
          <textarea
            class='m-2 block p-2 w-full text-white text-left whitespace-pre overflow-x-scroll'
          >{{this.result}}</textarea>
        </div>
      </p>
    </section>
    <footer><p class='text-center text-xs text-gray-500'>
        Check on
        <a
          href='https://github.com/lifeart/code2prompt/'
          class='text-blue-500'
        >GitHub</a></p></footer>
  </template>
}
