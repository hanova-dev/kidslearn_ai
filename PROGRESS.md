# KidsLearn AI — Progress (7th semester, ≈50% scope)

Status: **Not started** · **In progress** · **Done** (Done = works on the phone + analyze/tests clean + notes written + quiz passed, SRS 12.6.2).
Last update: 27 Oct 2026 (Week 1).

## Week 1 foundation
| Item | Owner | Status | Notes |
|---|---|---|---|
| Step 0 environment (Flutter, Java, Android SDK) | Both | Done | Tested on the emulator; the physical phone (vivo Y21) is still to connect |
| Step 0 free-tier check (Groq, Cloudflare, Firebase) | Hanan | Done | Decisions 012, 013, 014 |
| Project skeleton, folders, fonts, theme tokens (SRS 10.11) | Wahab | In progress | Splash works on the emulator; quiz not answered yet; no git repository found in this folder (26 Oct) |

## M1 — Account, RBAC and onboarding (Wahab)
| FR | Requirement (short) | Status | Notes |
|---|---|---|---|
| FR-AUTH-01 | Email/password sign-up and login | In progress | Screen + FirebaseAuthRepository built, 11 tests pass; real sign-up/log out/log in confirmed on emulator 26 Oct; waiting for quiz (decision 014) |
| FR-AUTH-02 | Child profile: name, buddy, age group, language | In progress | Add child screen + SQLite (decision 015); 19 tests pass; device test by team pending |
| FR-AUTH-03 | Parent screens only for signed-in parents | In progress | go_router redirect to /login; tested |
| FR-AUTH-04 | Parental gate (router guard) | In progress | go_router redirect + maths gate with number pad; decisions 003, 016; tested |
| FR-AUTH-05 | Profile picker (who's reading?) | In progress | Who's reading screen + activeChildProvider; path map is a placeholder until Week 3 |
| FR-AUTH-06 | Session kept locally (offline) | In progress | Splash goes straight to parent home when signed in; tested with fake |
| FR-HCI-01 | AgeExperiencePolicy (Listener/Reader) | Not started | |
| FR-HCI-04 | Fixed back/home/help positions (ChildScaffold) | Not started | |
| FR-HCI-05 | No solid red; colour + icon + sound | Not started | Decision 008 |

## M2 — Story generation (Hanan)
| FR | Requirement (short) | Status | Notes |
|---|---|---|---|
| FR-STORY-01 | Free-text prompt + language input | Not started | English only, decision 005 |
| FR-STORY-02 | StoryGenerationService → GroqStoryGenerator (JSON) | In progress | Spike works, decision 013 |
| FR-STORY-03 | Cache DRAFT in SQLite before network | Not started | |
| FR-STORY-04 | DRAFT / GENERATING / READY / FAILED + retry | Not started | |
| FR-STORY-05 | Reject too-short prompts | Not started | |
| FR-STORY-06 | Regenerate from same prompt | Not started | |
| FR-STORY-07 | Parent preview and approve | Not started | No design page; decision 011 |
| FR-STORY-08 | Real name → buddy name in prompts | Not started | Decision 001, 002 |

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
| NFR-REL-02 | 15 s timeout, 2 retries | Not started | Values in app_config.dart |
| NFR-REL-05 | Fallback adapter for every AI service | Not started | |
| NFR-PERF-01 | Verdict ≤ 300 ms | Not started | |
