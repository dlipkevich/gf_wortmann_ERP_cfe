﻿#Область ПрограммныйИнтерфейс

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2022/07/20
//
// Параметры:
//
// ПисьмоСсылка 	- ДокументСсылк
// Сообщение       	- ДокументСсылка
// МассивДокументов	- Массив
// УчетнаяЗапись	- СправочникСсылка
// АдресОтправителя	- Строка
// ПоставитьВКопию	- Булево
//
Процедура СоздатьИлиЗаполнитьПисьмо(ПисьмоСсылка, Сообщение, МассивДокументов,
	УчетнаяЗапись, АдресОтправителя = Неопределено, ПоставитьВКопию = Неопределено) Экспорт
	
	Если ЗначениеЗаполнено(ПисьмоСсылка)
		И ПисьмоСсылка.СтатусПисьма = ПредопределенноеЗначение("Перечисление.СтатусыИсходящегоЭлектронногоПисьма.Черновик") Тогда
		
		Письмо = ПисьмоСсылка.ПолучитьОбъект();
		
	Иначе
		
		Письмо = Документы.ЭлектронноеПисьмоИсходящее.СоздатьДокумент();
		
		Письмо.СтатусПисьма = ПредопределенноеЗначение("Перечисление.СтатусыИсходящегоЭлектронногоПисьма.Черновик");
		
	КонецЕсли;
	
	ПисьмоHTML = (Сообщение.ДополнительныеПараметры.ФорматПисьма = Перечисления.СпособыРедактированияЭлектронныхПисем.HTML);
	
	Письмо.Автор     = Пользователи.ТекущийПользователь();
	Письмо.Ответственный            = Пользователи.ТекущийПользователь();
	Письмо.Дата      = ТекущаяДатаСеанса();
	Письмо.Важность  = Перечисления.ВариантыВажностиВзаимодействия.Обычная;
	Письмо.Кодировка = "UTF-8";
	Письмо.ОтправительПредставление = АдресОтправителя;
	Письмо.Дата      = ТекущаяДатаСеанса();
	
	Если ПисьмоHTML Тогда
		
		Письмо.ТекстHTML = Сообщение.Текст;
		Письмо.Текст     = Взаимодействия.ПолучитьОбычныйТекстИзHTML(Сообщение.Текст);
		
	Иначе
		
		Письмо.Текст = Сообщение.Текст;
		
	КонецЕсли;
	
	Письмо.Тема      = Сообщение.Тема;
	Письмо.ТипТекста = ?(ПисьмоHTML, Перечисления.ТипыТекстовЭлектронныхПисем.HTML,
	Перечисления.ТипыТекстовЭлектронныхПисем.ПростойТекст);
	Письмо.УчетнаяЗапись           = УчетнаяЗапись;
	Письмо.ВзаимодействиеОснование = Неопределено;
	
	НастройкиПользователя = Взаимодействия.ПолучитьПараметрыРаботыПользователяДляИсходящегоЭлектронногоПисьма(
	УчетнаяЗапись, Сообщение.ДополнительныеПараметры.ФорматПисьма, Истина);
	ЗаполнитьЗначенияСвойств(Письмо, НастройкиПользователя);
	
	Письмо.УдалятьПослеОтправки = Ложь;
	Письмо.Комментарий          = "Создано и отправлено по шаблону" + " - " + Сообщение.ДополнительныеПараметры.Наименование;
	
	СписокПолучателейСпискомЗначений = (ТипЗнч(Сообщение.Получатель) = Тип("СписокЗначений"));
	
	Письмо["ПолучателиПисьма"].Очистить();
	
	Для Каждого ПолучательПисьма Из Сообщение.Получатель Цикл
		
		НоваяСтрока = Письмо["ПолучателиПисьма"].Добавить();
		
		Если СписокПолучателейСпискомЗначений Тогда
			
			НоваяСтрока.Адрес         = ПолучательПисьма.Значение;
			НоваяСтрока.Представление = ПолучательПисьма.Представление;
			
		Иначе
			
			НоваяСтрока.Адрес         = ПолучательПисьма.Адрес;
			НоваяСтрока.Представление = ПолучательПисьма.Представление;
			НоваяСтрока.Контакт       = ПолучательПисьма.ИсточникКонтактнойИнформации;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Письмо.СписокПолучателейПисьма = ВзаимодействияКлиентСервер.ПолучитьПредставлениеСпискаАдресатов(
	Письмо.ПолучателиПисьма,
	Ложь);
	
	Письмо.ПолучателиКопий.Очистить();
	
	МассивПолучателейКопий = СтрРазделить(ПоставитьВКопию, ";", Ложь);
	
	Для Каждого ПолучательКопии Из МассивПолучателейКопий Цикл
		
		СтрокаПолучателяКопии = Письмо.ПолучателиКопий.Добавить();
		
		СтрокаПолучателяКопии.Адрес = ПолучательКопии;
		
	КонецЦикла;
	
	Письмо.СписокПолучателейКопий = ВзаимодействияКлиентСервер.ПолучитьПредставлениеСпискаАдресатов(
	Письмо.ПолучателиКопий,
	Ложь);
	
	
	ОбработатьВложения(Письмо, Сообщение, МассивДокументов, ПисьмоHTML);
	
КонецПроцедуры

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/18
//
// Параметры:
//
// Письмо				- ДокументСсылка
// Сообщение			- ДокументСсылка
// МассивДокументов		- Массив	
// ПисьмоHTML			- Булевао
//
Процедура ОбработатьВложения(Письмо, Сообщение, МассивДокументов, ПисьмоHTML)
	
	Письмо.ЕстьВложения = (Сообщение.Вложения.Количество() > 0);
	
	РазмерВложений  = 0;
	РазмерыВложений = Новый Соответствие;
	
	Для Каждого Вложение Из Сообщение.Вложения Цикл
		
		Размер = ПолучитьИзВременногоХранилища(Вложение.АдресВоВременномХранилище).Размер() * 1.5;
		
		РазмерВложений = РазмерВложений + Размер;
		
		РазмерыВложений.Вставить(Вложение.АдресВоВременномХранилище, Размер);
		
		Если ЗначениеЗаполнено(Вложение.Идентификатор) Тогда
			
			Идентификатор = СтроковыеФункции.СтрокаЛатиницей(Вложение.Идентификатор);
			
			Письмо.ТекстHTML = СтрЗаменить(Письмо.ТекстHTML, "cid:" + Вложение.Идентификатор, "cid:" + Идентификатор);
			
			Вложение.Идентификатор = Идентификатор;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Письмо.Размер = РазмерВложений + СтрДлина(Письмо.Тема) * 2
	+ ?(ПисьмоHTML, СтрДлина(Письмо.ТекстHTML), СтрДлина(Письмо.Текст)) * 2;
	
	ПрикрепленныеДокументы = Письмо.гф_ПрикрепленныеДокументы;
	
	ПрикрепленныеДокументы.Очистить();
	
	Для Каждого Документ Из МассивДокументов Цикл
		
		ПрикрепленныйДокумент = ПрикрепленныеДокументы.Добавить();
		
		ПрикрепленныйДокумент.Документ = Документ;
		
	КонецЦикла;
	
	Письмо.Записать();
	
	ПисьмоСсылка = Письмо.Ссылка;
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = "ВЫБРАТЬ
	|	ЭлектронноеПисьмоИсходящееПрисоединенныеФайлы.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ЭлектронноеПисьмоИсходящееПрисоединенныеФайлы КАК ЭлектронноеПисьмоИсходящееПрисоединенныеФайлы
	|ГДЕ
	|	ЭлектронноеПисьмоИсходящееПрисоединенныеФайлы.ВладелецФайла = &ВладелецФайла";
	
	Запрос.Параметры.Вставить("ВладелецФайла", ПисьмоСсылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		ПрисоединеныйФайл = Выборка.Ссылка.ПолучитьОбъект();
		
		ПрисоединеныйФайл.Удалить();
		
	КонецЦикла;
	
	Для Каждого Вложение Из Сообщение.Вложения Цикл
		
		ПараметрыВложения = Новый Структура;
		ПараметрыВложения.Вставить("ИмяФайла", Вложение.Представление);
		ПараметрыВложения.Вставить("Размер",   РазмерыВложений[Вложение.АдресВоВременномХранилище]);
		
		Если ПустаяСтрока(Вложение.Идентификатор) Тогда
			
			УправлениеЭлектроннойПочтой.ЗаписатьВложениеЭлектронногоПисьмаИзВременногоХранилища(Письмо.Ссылка,
			Вложение.АдресВоВременномХранилище, ПараметрыВложения);
			
		ИначеЕсли ПисьмоHTML Тогда
			
			ПараметрыВложения.Вставить("ИДФайлаЭлектронногоПисьма", Вложение.Идентификатор);
			
			УправлениеЭлектроннойПочтой.ЗаписатьВложениеЭлектронногоПисьмаИзВременногоХранилища(Письмо.Ссылка,
			Вложение.АдресВоВременномХранилище, ПараметрыВложения);
			
		Иначе
			
			Продолжить; //Чтобы контроль кода не доколупался
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры// } #wortmann

// #wortmann {
// Галфинд Окунев 2022/07/20
//
// Параметры:
//
// Сообщение			- ДокументСсылка
// ИмяПараметра			- Строка
// ЗначениеПараметра	- Произвольный
//
Процедура ВставитьПараметрВТекстСообщения(Сообщение, ИмяПараметра, ЗначениеПараметра) Экспорт
	
	Сообщение.Текст = СтрЗаменить(Сообщение.Текст, "&lt;" + ИмяПараметра + "&gt;", ЗначениеПараметра);
	
КонецПроцедуры// } #wortmann

// #wortmann {
// Галфинд Окунев 2022/07/20
//
// Параметры:
//
// Сообщение	- ДокументСсылка
// Организация	- СправочникСсылка
//
Процедура ВставитьЛоготипВТекстСообщения(Сообщение, Организация) Экспорт
	
	ФайлКартинки = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Организация, "ФайлЛоготип");
	
	ДвоичныеДанныеФайла = РаботаСФайлами.ДвоичныеДанныеФайла(ФайлКартинки);
	
	АдресКартинки = ПоместитьВоВременноеХранилище(ДвоичныеДанныеФайла);
	
	ВставитьКартинкуВТекстСообщения(Сообщение, "Лого", АдресКартинки);
	
КонецПроцедуры

// #wortmann {
// Галфинд Окунев 2022/09/16
//
// Создает пустую таблицу печатных форм
//
// Возвращаемое значение:
// - ТаблицаЗначений - Колонки:
//
// Параметры:
//
//	Документ					- ДокументСсылка
//	ИдентификаторПечатнойФормы	- Строка
//	ПредставлениеПечатнойФормы	- Строка
//	ИмяФайла					- Строка - имя файла без пути,
//	ФорматФайла					- ТипФайлаТабличногоДокумента
//	Адрес						- Строка - адрес во временном хранилище.
//
Функция ИнициализироватьТаблицуПечатныхФорм() Экспорт
	
	ОписаниеТиповСтрока         = Новый ОписаниеТипов("Строка");
	ОписаниеТиповДокументСсылка = Документы.ТипВсеСсылки();
	ОписаниеТиповФорматФайла    = Новый ОписаниеТипов("ТипФайлаТабличногоДокумента");
	
	ТаблицаПечатныхФорм = Новый ТаблицаЗначений;
	
	ТаблицаПечатныхФорм.Колонки.Добавить("Документ",    ОписаниеТиповДокументСсылка);
	ТаблицаПечатныхФорм.Колонки.Добавить("ИдентификаторПечатнойФормы", ОписаниеТиповСтрока);
	ТаблицаПечатныхФорм.Колонки.Добавить("ПредставлениеПечатнойФормы", ОписаниеТиповСтрока);
	ТаблицаПечатныхФорм.Колонки.Добавить("ИмяФайла",    ОписаниеТиповСтрока);
	ТаблицаПечатныхФорм.Колонки.Добавить("ФорматФайла", ОписаниеТиповФорматФайла);
	ТаблицаПечатныхФорм.Колонки.Добавить("Адрес",       ОписаниеТиповСтрока);
	
	Возврат ТаблицаПечатныхФорм;
	
КонецФункции

// #wortmann {
// Галфинд Окунев 2022/09/16
//
// Формирует и помещает во временное хранилище печатные формы документа
//
// Параметры:
//
// ТаблицаПечатныхФорм			- Таблица значений 	- см. функцию ИнициализироватьТаблицуПечатныхФорм()
// УникальныйИдентификаторФормы	- УникальныйИдентификатор
// Ошибки						- Массив ошибок  - см. ОбщегоНазначенияКлиентСервер.ДобавитьОшибкуПользователю().
//
Процедура ВывестиДокументыВТаблицуПечатныхФорм(ТаблицаПечатныхФорм,
	УникальныйИдентификаторФормы,
	Ошибки = Неопределено) Экспорт
	
	Для Каждого ПечатнаяФорма Из ТаблицаПечатныхФорм Цикл
		
		ВывестиДокументВТаблицуПечатныхФорм(ПечатнаяФорма, УникальныйИдентификаторФормы, Ошибки)
		
	КонецЦикла;
	
КонецПроцедуры// } #wortmann

// #wortmann {
// Галфинд Окунев 2022/09/16
//
// Формирует и помещает во временное хранилище печатные формы документа
//
// Параметры:
//
// ПечатнаяФорма
// ТаблицаПечатныхФорм			- Таблица значений 	- см. функцию ИнициализироватьТаблицуПечатныхФорм()
// УникальныйИдентификаторФормы	- УникальныйИдентификатор
// Ошибки						- Массив ошибок  - см. ОбщегоНазначенияКлиентСервер.ДобавитьОшибкуПользователю().
//
Процедура ВывестиДокументВТаблицуПечатныхФорм(ПечатнаяФорма, УникальныйИдентификаторФормы, Ошибки = Неопределено)
	
	МассивОбъектов = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(ПечатнаяФорма.Документ);
	
	Если ЗначениеЗаполнено(ПечатнаяФорма.ФорматФайла) Тогда
		
		ФорматФайла = ПечатнаяФорма.ФорматФайла;
		
	Иначе
		
		ФорматФайла = ТипФайлаТабличногоДокумента.PDF;
		
	КонецЕсли;
	
	НастройкиСохранения = УправлениеПечатью.НастройкиСохранения();
	
	НастройкиСохранения.ФорматыСохранения.Добавить(ФорматФайла);
	
	КомандыПечати = УправлениеПечатью.КомандыПечатиОбъектаДоступныеДляВложений(ПечатнаяФорма.Документ.Метаданные());
	
	КомандаПечати = КомандыПечати.Найти(ПечатнаяФорма.ИдентификаторПечатнойФормы, "Идентификатор");
	
	Если КомандаПечати <> Неопределено Тогда
		
		ДанныеФайлов = УправлениеПечатью.НапечататьВФайл(КомандаПечати, МассивОбъектов, НастройкиСохранения);
		
		Если ДанныеФайлов.Количество() Тогда
			
			АдресФайла = ПоместитьВоВременноеХранилище(ДанныеФайлов[0].ДвоичныеДанные, УникальныйИдентификаторФормы);
			
			ПечатнаяФорма.Адрес = АдресФайла;
			
			Если Не ЗначениеЗаполнено(ПечатнаяФорма.ИмяФайла) Тогда
				
				ПечатнаяФорма.ИмяФайла = ДанныеФайлов[0].ИмяФайла;
				
			Иначе
				
				ПечатнаяФорма.ИмяФайла = ОбщегоНазначенияКлиентСервер.ЗаменитьНедопустимыеСимволыВИмениФайла(
				ПечатнаяФорма.ИмяФайла, "_");
				
			КонецЕсли;
			
		Иначе
			
			ОбщегоНазначенияКлиентСервер.ДобавитьОшибкуПользователю(Ошибки,
			"",
			СтрШаблон("Для документа %1 нет данных для печати формы %2",
			ПечатнаяФорма.Документ,
			ПечатнаяФорма.ПредставлениеПечатнойФормы));
			
		КонецЕсли
		
	Иначе
		
		ОбщегоНазначенияКлиентСервер.ДобавитьОшибкуПользователю(Ошибки,
		"",
		СтрШаблон("Для документа %1 не найдена команда печати для печатной формы %2",
		ПечатнаяФорма.Документ,
		ПечатнаяФорма.ПредставлениеПечатнойФормы));
		
	КонецЕсли;
	
КонецПроцедуры// } #wortmann

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// #wortmann {
// Галфинд Окунев 2022/07/20
// Параметры:
//
// Сообщение
// ИмяПараметра
// АдресКартинки
//
Процедура ВставитьКартинкуВТекстСообщения(Сообщение, ИмяПараметра, АдресКартинки) Экспорт
	
	Идентификатор = Строка(Новый УникальныйИдентификатор());
	
	Вложение = Сообщение.Вложения.Добавить();
	
	Вложение.АдресВоВременномХранилище = АдресКартинки;
	Вложение.Представление             = ИмяПараметра;
	Вложение.Идентификатор             = Идентификатор;
	
	Сообщение.Текст = СтрЗаменить(Сообщение.Текст,
	"&lt;" + ИмяПараметра + "&gt;",
	"<img src=""cid:" + Идентификатор + """ style=""border:none;""></img>");
	
КонецПроцедуры// } #wortmann

#КонецОбласти
