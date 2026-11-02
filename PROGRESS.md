# KidsLearn AI — Progress (7th semester, ≈50% scope)

Status: **Not started** · **In progress** · **Done** (Done = works on the phone + analyze/tests clean + notes written + quiz passed, SRS 12.6.2).
Last update: 2 Nov 2026 (Week 2, M2 task 3). Emulator test evidence: notes/images/device_test_2026-10-28/ and notes/images/m2_create_story_2026-11-02/.

## Week 1 foundation
| Item | Owner | Status | Notes |
|---|---|---|---|
| Step 0 environment (Flutter, Java, Android SDK) | Both | Done | Tested on the emulator; the physical phone (vivo Y21) is still to connect |
| Step 0 free-tier check (Groq, Cloudflare, Firebase) | Hanan | Done | Decisions 012, 013, 014 |
| Project skeleton, folders, fonts, theme tokens (SRS 10.11) | Wahab | In progress | Splash works on the emulator; night mode checked on emulator 28 Oct; quiz not answered yet; first commit 3189b3c pushed to private repo hanova-dev/kidslearn_ai, tag v0.1-m1-week1 (28 Oct) |

## M1 — Account, RBAC and onboarding (Wahab)
| FR | Requirement (short) | Status | Notes |
|---|---|---|---|
| FR-AUTH-01 | Email/password sign-up and login | In progress | Widget tests pass. **Emulator 28 Oct:** sign-up (Firebase session file created), log out, log in OK; wrong-password message seen by team. Waiting for quiz (decision 014) |
| FR-AUTH-02 | Child profile: name, buddy, age group, language | In progress | Widget tests pass. **Emulator 28 Oct:** empty-form messages shown; child saved (1 SQLite row: mango, reader_5_7, en). Bug found (old messages stayed after fixing a field) → fixed + test, re-checked on emulator. Waiting for quiz |
| FR-AUTH-03 | Parent screens only for signed-in parents | In progress | go_router redirect to /login. **Emulator 28 Oct:** signed-out start and log out both land on login. Waiting for quiz |
| FR-AUTH-04 | Parental gate (router guard) | In progress | Router guard + maths gate (decisions 003, 016). **Emulator 28 Oct:** wrong answer → new sum; right answer → parent home. Waiting for quiz |
| FR-AUTH-05 | Profile picker (who's reading?) | In progress | **Emulator 28 Oct:** child card shown; tap → "Hi, Ali!"; Home returns. Path map is a placeholder until Week 3. Waiting for quiz |
| FR-AUTH-06 | Session kept locally (offline) | In progress | **Emulator 28 Oct:** force-close while unlocked → reopens on Who's reading, locked, still signed in, child kept (decision 016). Waiting for quiz |
| FR-HCI-01 | AgeExperiencePolicy (Listener/Reader) | Not started | |
| FR-HCI-04 | Fixed back/home/help positions (ChildScaffold) | Not started | |
| FR-HCI-05 | No solid red; colour + icon + sound | Not started | Decision 008 |

## M2 — Story generation (Hanan)
| FR | Requirement (short) | Status | Notes |
|---|---|---|---|
| FR-STORY-01 | Free-text prompt + language input | In progress | Create story screen (p7): text or value chip, child chips, English only (decisions 005, 019). **Emulator 2 Nov:** real Groq story for Sara ("Sky Shares Her Colors", 6 scenes). Waiting for quiz |
| FR-STORY-02 | StoryGenerationService → GroqStoryGenerator (JSON) | In progress | Service + adapter built, 7 mocked tests, real call OK 28 Oct (decisions 013, 017); used by screens in task 3 |
| FR-STORY-03 | Cache DRAFT in SQLite before network | In progress | StoryCreationController saves DRAFT before the Groq call (test checks the order). **Emulator 2 Nov:** offline story row saved with prompt_value 'Kindness'. Waiting for quiz (decisions 018, 019) |
| FR-STORY-04 | DRAFT / GENERATING / READY / FAILED + retry | In progress | Story generating screen (p8) + Try again. **Emulator 2 Nov:** writing screen seen; offline → "No internet…" + row FAILED; online + Try again → same story READY, 6 scenes. READY comes before pictures until M3. Waiting for quiz |
| FR-STORY-05 | Reject too-short prompts | In progress | StoryInputCheck, 15–300 letters in AppConfig, 6 tests. **Emulator 2 Nov:** empty → "Tell us what the story should teach…"; "Sara hits" → "Please write a little more…"; nothing sent. Waiting for quiz |
| FR-STORY-06 | Regenerate from same prompt | Not started | |
| FR-STORY-07 | Parent preview and approve | Not started | No design page; decision 011 |
| FR-STORY-08 | Real name → buddy name in prompts | In progress | StoryPromptBuilder.redactName, 8 tests + controller test (decision 017). **Emulator 2 Nov:** prompt "Sara does not want…" → story about Sky; "Sara" not found in title, character sheet or scenes. Waiting for quiz |

## M3 — Illustration (Hanan)
| FR | Requirement (short) | Status | Notes |
|---|---|---|---|
| FR-ILLUS-01 | IllustrationService → FluxIllustrator + character sheet | In progress | Spike works; no seed (decision 012) |
| FR-ILLUS-02 | Image saved as file, path in SQLite | Not started | |
| FR-ILLUS-03 | Show scenes progressively | Not started | |
| FR-ILLUS-04 | Retry one failed scene | Not started | NSFW false alarm seen in spike |
| FR-ILLUS-05 | Choose 512 / 1024 resolution | Dropped | Not supported by the API (decision 012) |
| FR-ILLUS-06 | PlaceholderIllustrator fallback | Not started | Drawn in Flutter, decision 010 |

## M4 — Speech-to-text (Hanan)
| FR | Requirement (short) | Status | Notes |
|---|---|---|---|
| FR-STT-01 | Mic only while the child triggers it | Not started | |
| FR-STT-02 | SpeechToTextService → GroqWhisperTranscriber | In progress | Spike works (0.7 s) |
| FR-STT-03 | Language from child profile | Not started | English only, decision 005 |
| FR-STT-04 | Delete audio after transcription | Not started | |
| FR-STT-05 | Retry when no speech detected | Not started | |
| FR-STT-06 | One sentence per request | Not started | Decision 004 |
| FR-STT-07 | DeviceSpeechRecognizer fallback | Not started | Needs the physical phone |

## M5 — PhoneticScorer (Hanan)
| FR | Requirement (short) | Status | Notes |
|---|---|---|---|
| FR-SCORE-01 | Double Metaphone codes | Not started | Package vs own subset: team must choose |
| FR-SCORE-02 | Levenshtein distance | Not started | Tests first |
| FR-SCORE-03 | Normalised similarity | Not started | |
| FR-SCORE-04 | CORRECT / NEAR_MISS / TRY_AGAIN | Not started | |
| FR-SCORE-05 | Per-language thresholds | Not started | |
| FR-SCORE-06 | Practice-word list | Not started | |
| FR-SCORE-07 | Colours within 300 ms | Not started | Benchmark on the phone |
| FR-SCORE-08 | Word alignment (SRS 8.1.6) | Not started | Tests first |

## M6 (partial) — Basic Reader Mode (Wahab)
| FR | Requirement (short) | Status | Notes |
|---|---|---|---|
| FR-MODE-01 | Mode by age group | Not started | Simple viewer for 2–4, decision 006 |
| FR-MODE-04 | Tap-and-read before advancing | Not started | Whole sentence, decision 004 |
| FR-MODE-05 | Live colour feedback | Not started | |
| FR-MODE-06 | Stars on completion (simple) | Not started | Decision 009 |

## Cross-cutting
| ID | Requirement (short) | Status | Notes |
|---|---|---|---|
| NFR-SEC-03 | Keys never in source control | In progress | env/ in .gitignore; check before first commit |
| NFR-USE-03 | Plain-language errors with retry | In progress | Login errors mapped to plain sentences (AuthFailure) |
| NFR-REL-02 | 15 s timeout, 2 retries | In progress | Done for Groq story calls; FLUX and Whisper later |
| NFR-REL-05 | Fallback adapter for every AI service | Not started | |
| NFR-PERF-01 | Verdict ≤ 300 ms | Not started | |
